require 'spec_helper'

describe 'Token Endpoint' do
  subject { -> { post url, params } }

  let(:url) { '/oauth/token' }
  let(:client) { Client.create(name: FFaker::Internet.domain_word, redirect_uri: 'http://localhost:3000/home') }
  let(:user) { User.create(username: FFaker::Internet.user_name, encrypted_password: FFaker::Internet.password) }
  let(:grant_type) { 'password' }
  let(:scopes) { 'read,write' }
  let(:username) { user.username }
  let(:password) { user.encrypted_password }
  let(:client_id) { client.key }
  let(:client_secret) { client.secret }
  let(:params) do
    {
      username: username,
      password: password,
      client_id: client_id,
      client_secret: client_secret,
      grant_type: grant_type,
      scope: scopes
    }
  end

  describe 'POST /oauth/token' do
    describe 'Password flow' do
      before { subject.call }

      context 'when invalid params' do
        context 'without username' do
          let(:username) {}

          it { expect(AccessToken.count).to be_zero }
          it { expect(json_body[:error]).to eq('invalid_request') }
          it { expect(json_body[:error_description]).to eq("'username' required.") }
          it { expect(last_response.status).to eq 400 }
        end

        context 'with invalid username' do
          let(:username) { 'invalid@example.com' }
          let(:error_description) do
            'The provided access grant is invalid, expired, or revoked (e.g. invalid assertion, '\
            'expired authorization token, bad end-user password credentials, '\
            'or mismatching authorization code and redirection URI).'
          end

          it { expect(AccessToken.count).to be_zero }
          it { expect(json_body[:error]).to eq('invalid_grant') }
          it { expect(json_body[:error_description]).to eq(error_description) }
          it { expect(last_response.status).to eq 400 }
        end

        context 'without password' do
          let(:password) {}

          it { expect(AccessToken.count).to be_zero }
          it { expect(json_body[:error]).to eq('invalid_request') }
          it { expect(json_body[:error_description]).to eq("'password' required.") }
          it { expect(last_response.status).to eq 400 }
        end

        context 'with invalid password' do
          let(:password) { 'invalid@password.com' }
          let(:error_description) do
            'The provided access grant is invalid, expired, or revoked (e.g. invalid assertion, '\
            'expired authorization token, bad end-user password credentials, '\
            'or mismatching authorization code and redirection URI).'
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

      context 'when valid params' do
        context 'return AccessToken' do
          it { expect(AccessToken.count).to eq 1 }
          it { expect(AccessToken.first.client_id).to eq(client.id) }
          it { expect(AccessToken.first.resource_owner_id).to eq(user.id) }

          it { expect(last_response.status).to eq 200 }
          it { expect(json_body[:access_token]).to be_present }
          it { expect(json_body[:token_type]).to eq 'bearer' }
          it { expect(json_body[:expires_in]).to eq 7200 }
          it { expect(json_body[:refresh_token]).to be_nil }
          it { expect(json_body[:scope]).to eq('read,write') }
        end

        context 'return AccessToken without scopes' do
          let(:scopes) {}

          it { expect(AccessToken.count).to eq 1 }
          it { expect(AccessToken.first.client_id).to eq(client.id) }
          it { expect(AccessToken.first.resource_owner_id).to eq(user.id) }

          it { expect(last_response.status).to eq 200 }
          it { expect(json_body[:access_token]).to be_present }
          it { expect(json_body[:token_type]).to eq 'bearer' }
          it { expect(json_body[:expires_in]).to eq 7200 }
          it { expect(json_body[:refresh_token]).to be_nil }
          it { expect(json_body[:scope]).to be_nil }
        end
      end
    end
  end
end
