require 'spec_helper'

describe 'Token Endpoint' do
  subject { -> { post url, params } }

  let(:url) { '/oauth/token' }
  let(:client) { Client.create(attributes_for(:client)) }
  let(:user) { User.create(attributes_for(:user)) }
  let(:grant_type) { 'password' }
  let(:scopes) { 'read,write' }
  let(:params) do
    {
      username: user.username,
      password: user.encrypted_password,
      client_id: client.key,
      client_secret: client.secret,
      grant_type: grant_type,
      scope: scopes
    }
  end

  describe 'POST /oauth/token' do
    describe 'password flow' do
      before { subject.call }

      context 'when invalid params' do
        context 'without GrantType' do
          let(:grant_type) {}

          it { expect(AccessToken.count).to be_zero }
          it { expect(json_body[:error]).to eq('invalid_request') }
          it { expect(json_body[:error_description]).to eq("'grant_type' required.") }
          it { expect(last_response.status).to eq 400 }
        end

        context 'with invalid GrantType' do
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

        context 'without Client Credentials' do
          let(:params) do
            {
              username: user.username,
              password: user.encrypted_password,
              grant_type: grant_type
            }
          end

          it { expect(AccessToken.count).to be_zero }
          it { expect(json_body[:error]).to eq('invalid_request') }
          it { expect(json_body[:error_description]).to eq("'client_id' required.") }
          it { expect(last_response.status).to eq 400 }
        end

        context 'with invalid Client Credentials' do
          let(:params) do
            {
              username: user.username,
              password: user.encrypted_password,
              client_id: 'asdasd',
              client_secret: client.secret,
              grant_type: grant_type
            }
          end
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

        context 'without Resource Owner credentials' do
          let(:params) do
            {
              client_id: client.key,
              client_secret: client.secret,
              grant_type: grant_type
            }
          end

          it { expect(AccessToken.count).to be_zero }
          it { expect(json_body[:error]).to eq('invalid_request') }
          it { expect(json_body[:error_description]).to eq("'username', 'password' required.") }
          it { expect(last_response.status).to eq 400 }
        end

        context 'with invalid Resource Owner credentials' do
          let(:params) do
            {
              username: 'invalid@example.com',
              password: user.encrypted_password,
              client_id: client.key,
              client_secret: client.secret,
              grant_type: grant_type
            }
          end
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

          context 'without scopes' do
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
end
