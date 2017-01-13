require 'spec_helper'

describe 'RevokeToken Endpoint' do
  subject { -> { post url, params } }

  let(:url) { '/oauth/revoke_token' }
  let(:user) { User.create(username: FFaker::Internet.user_name, encrypted_password: FFaker::Internet.password) }
  let(:client) { Client.create(name: FFaker::Internet.domain_word, redirect_uri: 'http://localhost:3000/home') }
  let(:access_token) { AccessToken.create_for(client, user) }
  let(:client_id) { client.key }
  let(:refresh_token) { access_token.refresh_token }
  let(:params) do
    {
      client_id: client_id,
      token: refresh_token
    }
  end

  describe 'POST /oauth/revoke_token' do
    before do
      allow(Simple::OAuth2.config).to receive(:issue_refresh_token).and_return(true)
      subject.call
    end

    context 'with valid params' do
      it { expect(last_response.status).to eq 200 }
      it { expect(last_response.header).to be_empty }
      it { expect(last_response.body).to be_empty }

      it { expect(access_token.reload.refresh_token).to_not be_nil }
      it { expect(access_token.reload.revoked_at).to_not be_nil }
    end

    context 'with invalid params' do
      context 'without client_id' do
        let(:client_id) {}
        let(:error_description) do
          'The client identifier provided is invalid, the client failed to authenticate, '\
          'the client did not include its credentials, provided multiple client credentials, '\
          'or used unsupported credentials type.'
        end

        it { expect(last_response.status).to eq 401 }
        it { expect(json_body[:error]).to eq 'invalid_client' }
        it { expect(json_body[:error_description]).to eq error_description }

        it { expect(access_token.reload.refresh_token).to_not be_nil }
        it { expect(access_token.reload.revoked_at).to be_nil }
      end

      context 'when client_id invalid' do
        let(:client_id) { 'invalid' }
        let(:error_description) do
          'The client identifier provided is invalid, the client failed to authenticate, '\
          'the client did not include its credentials, provided multiple client credentials, '\
          'or used unsupported credentials type.'
        end

        it { expect(last_response.status).to eq 401 }
        it { expect(json_body[:error]).to eq 'invalid_client' }
        it { expect(json_body[:error_description]).to eq error_description }

        it { expect(access_token.reload.refresh_token).to_not be_nil }
        it { expect(access_token.reload.revoked_at).to be_nil }
      end

      context 'without token' do
        let(:refresh_token) {}

        it { expect(last_response.status).to eq 200 }
        it { expect(last_response.header).to be_empty }
        it { expect(last_response.body).to be_empty }

        it { expect(access_token.reload.refresh_token).to_not be_nil }
        it { expect(access_token.reload.revoked_at).to be_nil }
      end

      context 'when token invalid' do
        let(:refresh_token) { 'invalid' }

        it { expect(last_response.status).to eq 200 }
        it { expect(last_response.header).to be_empty }
        it { expect(last_response.body).to be_empty }

        it { expect(access_token.reload.refresh_token).to_not be_nil }
        it { expect(access_token.reload.revoked_at).to be_nil }
      end
    end
  end
end
