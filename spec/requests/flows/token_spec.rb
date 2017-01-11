require 'spec_helper'

describe 'Authorization Endpoint' do
  subject { -> { post url, params } }

  let(:url) { '/oauth/authorization' }
  let!(:user) { User.create(username: FFaker::Internet.user_name, encrypted_password: FFaker::Internet.password) }
  let(:client) { Client.create(name: FFaker::Internet.domain_word, redirect_uri: 'http://localhost:3000/home') }
  let(:client_id) { client.key }
  let(:redirect_uri) { client.redirect_uri }
  let(:response_type) { 'token' }
  let(:state) { nil }
  let(:scope) { nil }
  let(:params) do
    {
      client_id: client_id,
      redirect_uri: redirect_uri,
      response_type: response_type,
      state: state,
      scope: scope
    }
  end

  describe 'POST /oauth/custom_authorization' do
    let(:url) { '/oauth/custom_authorization' }

    before { subject.call }

    context 'invokes custom block' do
      it { expect(last_response.status).to eq(400) }
    end
  end

  describe 'POST /oauth/authorization' do
    describe 'Token flow' do
      before { subject.call }

      context 'when valid params' do
        let(:access_token) { AccessToken.last.token }
        let(:response_header) do
          "#{client.redirect_uri}#access_token=#{access_token}&expires_in=7200&token_type=bearer"
        end

        it { expect(AccessToken.count).to eq 1 }
        it { expect(AccessToken.last.scopes).to be_empty }
        it { expect(AccessToken.last.resource_owner.username).to eq user.username }
        it { expect(last_response.status).to eq 302 }
        it { expect(last_response.headers['Location']).to eq response_header }

        context 'without redirect_uri' do
          let(:redirect_uri) {}

          it { expect(last_response.headers['Location']).to eq response_header }
        end

        context 'with state' do
          let(:state) { 'zxc' }
          let(:response_header_with_state) do
            "#{client.redirect_uri}#access_token=#{access_token}&expires_in=7200&state=#{state}&token_type=bearer"
          end

          it { expect(last_response.headers['Location']).to eq response_header_with_state }
        end

        context 'with scopes' do
          let(:scope) { 'read,write' }

          it { expect(AccessToken.last.scopes).to eq 'read,write' }
        end
      end

      context 'when invalid params' do
        context 'without client_id' do
          let(:client_id) {}

          it { expect(last_response.status).to eq 400 }
          it { expect(json_body[:error]).to eq('bad_request') }
        end

        context 'with invalid client_id' do
          let(:client_id) { 'invalid' }

          it { expect(last_response.status).to eq 400 }
          it { expect(json_body[:error]).to eq('bad_request') }
        end

        context 'with invalid redirect_uri' do
          let(:redirect_uri) { 'invalid' }

          it { expect(last_response.status).to eq 400 }
          it { expect(json_body[:error]).to eq('bad_request') }
        end

        context 'without response_type' do
          let(:response_type) {}

          it { expect(last_response.status).to eq 400 }
          it { expect(json_body[:error]).to eq('invalid_request') }
          it { expect(json_body[:error_description]).to eq "'response_type' required." }
        end

        context 'with invalid response_type' do
          let(:response_type) { 'invalid' }
          let(:error_description) { 'The requested response type is not supported by the authorization server.' }

          it { expect(last_response.status).to eq 400 }
          it { expect(json_body[:error]).to eq 'unsupported_response_type' }
          it { expect(json_body[:error_description]).to eq error_description }
        end
      end
    end
  end
end
