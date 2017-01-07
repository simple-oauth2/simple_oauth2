require 'spec_helper'

describe 'Token Endpoint' do
  subject { -> { post url, params } }

  let(:url) { '/oauth/token' }
  let(:client) { Client.create(name: FFaker::Internet.domain_word, redirect_uri: 'http://localhost:3000/home') }
  let(:user) { User.create(username: FFaker::Internet.user_name, encrypted_password: FFaker::Internet.password) }
  let(:client_id) { client.key }
  let(:client_secret) { client.secret }
  let(:grant_type) { 'refresh_token' }
  let(:scopes) { nil }
  let(:access_token) { AccessToken.create_for(client, user, scopes) }
  let(:refresh_token) { access_token.refresh_token }
  let(:params) do
    {
      client_id: client_id,
      client_secret: client_secret,
      refresh_token: refresh_token,
      grant_type: grant_type,
      scope: scopes
    }
  end

  describe 'POST /oauth/token' do
    describe 'RefreshToken flow' do
      context 'when valid params' do
        context 'return a new Access Token' do
          before do
            allow(Simple::OAuth2.config).to receive(:issue_refresh_token).and_return(true)
            subject.call
          end

          it { expect(last_response.status).to eq 200 }

          it { expect(AccessToken.count).to eq 2 }
          it { expect(AccessToken.last.client_id).to eq client.id }
          it { expect(AccessToken.last.resource_owner_id).to eq user.id }
          it { expect(AccessToken.last.scopes).to be_empty }

          it { expect(json_body[:access_token]).to eq AccessToken.last.token }
          it { expect(json_body[:token_type]).to eq 'bearer' }
          it { expect(json_body[:expires_in]).to eq 7200 }
          it { expect(json_body[:refresh_token]).to eq AccessToken.last.refresh_token }
        end

        context 'returns a new Access Token even if used token is expired' do
          before do
            allow(Simple::OAuth2.config).to receive(:issue_refresh_token).and_return(true)
            access_token.update(expires_at: Time.now - 604_800) # - 7 days
            subject.call
          end

          it { expect(access_token.refresh_token).not_to be_nil }
          it { expect(last_response.status).to eq 200 }

          it { expect(AccessToken.count).to eq 2 }
          it { expect(AccessToken.last.client_id).to eq client.id }
          it { expect(AccessToken.last.resource_owner_id).to eq user.id }
          it { expect(AccessToken.last.scopes).to be_empty }

          it { expect(json_body[:access_token]).to eq AccessToken.last.token }
          it { expect(json_body[:token_type]).to eq 'bearer' }
          it { expect(json_body[:expires_in]).to eq 7200 }
          it { expect(json_body[:refresh_token]).to eq AccessToken.last.refresh_token }
        end

        context 'return a new Access Token with scopes' do
          before do
            allow(Simple::OAuth2.config).to receive(:issue_refresh_token).and_return(true)
            subject.call
          end

          let(:scopes) { 'read' }

          it { expect(AccessToken.count).to eq 2 }
          it { expect(AccessToken.last.scopes).to eq 'read' }

          it { expect(json_body[:scope]).to eq 'read' }
        end

        context 'revokes old Access Token if it is configured' do
          before do
            allow(Simple::OAuth2.config).to receive(:issue_refresh_token).and_return(true)
            allow(Simple::OAuth2.config).to receive(:on_refresh).and_return(:revoke!)
            subject.call
          end

          it { expect(last_response.status).to eq 200 }

          it { expect(AccessToken.count).to eq 2 }
          it { expect(AccessToken.last.client_id).to eq client.id }
          it { expect(AccessToken.last.resource_owner_id).to eq user.id }

          it { expect(access_token.reload.revoked?).to be_truthy }

          it { expect(json_body[:access_token]).to eq AccessToken.last.token }
          it { expect(json_body[:refresh_token]).to eq AccessToken.last.refresh_token }
        end

        context 'destroy old Access Token if it is configured' do
          before do
            allow(Simple::OAuth2.config).to receive(:issue_refresh_token).and_return(true)
            allow(Simple::OAuth2.config).to receive(:on_refresh).and_return(:destroy)
            subject.call
          end

          it { expect(last_response.status).to eq 200 }

          it { expect(AccessToken.count).to eq 1 }
          it { expect(AccessToken.where(token: access_token.token).first).to be_nil }

          it { expect(json_body[:access_token]).to eq AccessToken.last.token }
          it { expect(json_body[:token_type]).to eq 'bearer' }
          it { expect(json_body[:expires_in]).to eq 7200 }
          it { expect(json_body[:refresh_token]).to eq AccessToken.last.refresh_token }
        end

        context 'calls custom block on token refresh if it is configured' do
          before do
            allow(Simple::OAuth2.config).to receive(:issue_refresh_token).and_return(true)
            allow(Simple::OAuth2.config).to receive(:on_refresh).and_return(
              ->(token) { token.update(scopes: scopes) }
            )
            subject.call
          end
          let(:scopes) { 'for example' }

          it { expect(last_response.status).to eq 200 }

          it { expect(AccessToken.count).to eq 2 }
          it { expect(access_token.reload.scopes).to eq(scopes) }
        end

        context 'does nothing on token refresh if :on_refresh is equal to' do
          context ':nothing' do
            before do
              allow(Simple::OAuth2.config).to receive(:issue_refresh_token).and_return(true)
              allow(Simple::OAuth2.config).to receive(:on_refresh).and_return(:nothing)
              subject.call
            end

            it { expect(Simple::OAuth2::Strategies::RefreshToken).not_to receive(:run_callback_on_refresh_token) }
            it { expect(last_response.status).to eq 200 }
          end

          context 'nil' do
            before do
              allow(Simple::OAuth2.config).to receive(:issue_refresh_token).and_return(true)
              allow(Simple::OAuth2.config).to receive(:on_refresh).and_return(nil)
              subject.call
            end

            it { expect(Simple::OAuth2::Strategies::RefreshToken).not_to receive(:run_callback_on_refresh_token) }
            it { expect(last_response.status).to eq 200 }
          end
        end
      end

      context 'when invalid params' do
        before do
          allow(Simple::OAuth2.config).to receive(:issue_refresh_token).and_return(true)
          subject.call
        end

        context 'without client_id' do
          let(:client_id) {}

          it { expect(AccessToken.count).to eq 1 }

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

          it { expect(AccessToken.count).to eq 1 }

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

          it { expect(AccessToken.count).to eq 1 }

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

          it { expect(AccessToken.count).to eq 1 }

          it { expect(json_body[:error]).to eq('invalid_client') }
          it { expect(json_body[:error_description]).to eq(error_description) }
          it { expect(last_response.status).to eq 401 }
        end

        context 'without refresh_token' do
          let(:refresh_token) {}

          it { expect(AccessToken.count).to be_zero }

          it { expect(json_body[:error]).to eq('invalid_request') }
          it { expect(json_body[:error_description]).to eq("'refresh_token' required.") }
          it { expect(last_response.status).to eq 400 }
        end

        context 'with invalid refresh_token' do
          let(:refresh_token) { 'invalid' }
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

        context 'without grant_type' do
          let(:grant_type) {}

          it { expect(AccessToken.count).to eq 1 }

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

          it { expect(AccessToken.count).to eq 1 }

          it { expect(json_body[:error]).to eq('unsupported_grant_type') }
          it { expect(json_body[:error_description]).to eq(error_description) }
          it { expect(last_response.status).to eq 400 }
        end
      end
    end
  end
end
