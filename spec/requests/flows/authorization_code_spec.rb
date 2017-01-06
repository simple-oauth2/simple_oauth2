require 'spec_helper'

describe 'Token Endpoint' do
  subject { -> { post url, params } }

  let(:url) { '/oauth/token' }
  let(:client) { Client.create(attributes_for(:client)) }
  let(:user) { User.create(attributes_for(:user)) }
  let(:grant_type) { 'authorization_code' }
  let(:client_id) { client.key }
  let(:client_secret) { client.secret }
  let(:scopes) { nil }
  let(:redirect_uri) { 'localhost:3000/home' }
  let(:another_redirect_uri) { redirect_uri }
  let(:access_grant) { AccessGrant.create_for(client, user, redirect_uri, scopes) }
  let(:code) { access_grant.token }
  let(:params) do
    {
      code: code,
      redirect_uri: another_redirect_uri,
      client_id: client_id,
      client_secret: client_secret,
      grant_type: grant_type
    }
  end

  describe 'POST /oauth/token' do
    describe 'AuthorizationCode flow' do
      before { subject.call }

      context 'when valid params' do
        it { expect(AccessToken.count).to eq 1 }
        it { expect(last_response.status).to eq 200 }
        it { expect(json_body[:access_token]).not_to be_nil }
        it { expect(json_body[:token_type]).to eq 'bearer' }
        it { expect(json_body[:expires_in]).to eq 7200 }
      end

      context 'when invalid params' do
        context 'without code' do
          let(:code) {}

          it { expect(AccessToken.count).to be_zero }
          it { expect(json_body[:error]).to eq('invalid_request') }
          it { expect(json_body[:error_description]).to eq("'code' required.") }
          it { expect(last_response.status).to eq 400 }
        end

        context 'with invalid code' do
          let(:code) { 'invalid' }
          let(:error_description) do
            'The provided access grant is invalid, expired, or revoked '\
            '(e.g. invalid assertion, expired authorization token, '\
            'bad end-user password credentials, or mismatching authorization code and redirection URI).'
          end

          it { expect(AccessToken.count).to be_zero }
          it { expect(json_body[:error]).to eq('invalid_grant') }
          it { expect(json_body[:error_description]).to eq(error_description) }
          it { expect(last_response.status).to eq 400 }
        end

        context 'without redirect_uri' do
          let(:redirect_uri) {}
          let(:error_description) do
            'The provided access grant is invalid, expired, or revoked '\
            '(e.g. invalid assertion, expired authorization token, '\
            'bad end-user password credentials, or mismatching authorization code and redirection URI).'
          end

          it { expect(AccessToken.count).to be_zero }
          it { expect(json_body[:error]).to eq('invalid_grant') }
          it { expect(json_body[:error_description]).to eq(error_description) }
          it { expect(last_response.status).to eq 400 }
        end

        context 'with invalid redirect_uri' do
          let(:another_redirect_uri) { 'invalid' }

          let(:error_description) do
            'The provided access grant is invalid, expired, or revoked '\
            '(e.g. invalid assertion, expired authorization token, '\
            'bad end-user password credentials, or mismatching authorization code and redirection URI).'
          end

          it { expect(AccessToken.count).to be_zero }
          it { expect(json_body[:error]).to eq('invalid_grant') }
          it { expect(json_body[:error_description]).to eq(error_description) }
          it { expect(last_response.status).to eq 400 }
        end

        context 'without client_id' do
          let(:client_id) {}

          it { expect(AccessToken.count).to be_zero }
          it { expect(json_body[:error]).to eq('invalid_request') }
          it { expect(json_body[:error_description]).to eq("'client_id' required.") }
          it { expect(last_response.status).to eq 400 }
        end

        context 'with invalid client_id' do
          let(:client_id) { 'invalid' }
          let(:error_description) do
            'The client identifier provided is invalid, the client failed to authenticate, '\
            'the client did not include its credentials, provided multiple client credentials, '\
            'or used unsupported credentials type.'
          end

          it { expect(AccessToken.count).to be_zero }
          it { expect(json_body[:error]).to eq('invalid_client') }
          it { expect(json_body[:error_description]).to eq(error_description) }
          it { expect(last_response.status).to eq 401 }
        end

        context 'without client_secret' do
          let(:client_secret) {}
          let(:error_description) do
            'The client identifier provided is invalid, the client failed to authenticate, '\
            'the client did not include its credentials, provided multiple client credentials, '\
            'or used unsupported credentials type.'
          end

          it { expect(AccessToken.count).to be_zero }
          it { expect(json_body[:error]).to eq('invalid_client') }
          it { expect(json_body[:error_description]).to eq(error_description) }
          it { expect(last_response.status).to eq 401 }
        end

        context 'with invalid client_secret' do
          let(:client_secret) { 'invalid' }
          let(:error_description) do
            'The client identifier provided is invalid, the client failed to authenticate, '\
            'the client did not include its credentials, provided multiple client credentials, '\
            'or used unsupported credentials type.'
          end

          it { expect(AccessToken.count).to be_zero }
          it { expect(json_body[:error]).to eq('invalid_client') }
          it { expect(json_body[:error_description]).to eq(error_description) }
          it { expect(last_response.status).to eq 401 }
        end

        context 'without grant_type' do
          let(:grant_type) {}

          it { expect(AccessToken.count).to be_zero }
          it { expect(json_body[:error]).to eq('invalid_request') }
          it { expect(json_body[:error_description]).to eq("'grant_type' required.") }
          it { expect(last_response.status).to eq 400 }
        end

        context 'with invalid grant_type' do
          let(:grant_type) { 'invalid' }
          let(:error_description) do
            'The access grant included - '\
            'its type or another attribute - '\
            'is not supported by the authorization server.'
          end

          it { expect(AccessToken.count).to be_zero }
          it { expect(json_body[:error]).to eq('unsupported_grant_type') }
          it { expect(json_body[:error_description]).to eq(error_description) }
          it { expect(last_response.status).to eq 400 }
        end
      end
    end
  end
end
