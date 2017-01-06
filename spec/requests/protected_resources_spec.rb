require 'spec_helper'

describe 'GET Protected Resources' do
  subject { -> { get url, params } }

  let(:url) { '/api/v1/status' }
  let(:client) { Client.create(attributes_for(:client)) }
  let(:user) { User.create(attributes_for(:user)) }
  let(:scopes) { nil }
  let(:access_token) { AccessToken.create_for(client, user, scopes) }
  let(:params) { { access_token: access_token.token } }

  before { subject.call }

  context 'with invalid data' do
    context 'returns Unauthorized without access_token' do
      let(:params) {}

      it { expect(last_response.status).to eq 401 }
      it { expect(json_body[:error]).to eq 'unauthorized' }
      it { expect(last_response.headers['WWW-Authenticate']).to eq('Bearer realm="Custom Realm"') }
    end

    context 'returns Unauthorized when token scopes are blank' do
      let(:url) { '/api/v1/status/single_scope' }

      it { expect(last_response.status).to eq 403 }
      it { expect(json_body[:error]).to eq 'forbidden' }
    end

    context "returns Unauthorized when token scopes doesn't match required scopes" do
      let(:url) { '/api/v1/status/multiple_scopes' }
      let(:scopes) { 'read' }

      it { expect(last_response.status).to eq 403 }
      it { expect(json_body[:error]).to eq 'forbidden' }
    end
  end

  context 'with valid data' do
    context "returns status for endpoint that doesn't requires any scope" do
      it { expect(last_response.status).to eq 200 }
      it { expect(json_body[:value]).to eq('Access') }
      it { expect(json_body[:current_user_name]).not_to be_nil }
    end

    context 'returns status for endpoint with specific scope' do
      let(:url) { '/api/v1/status/single_scope' }
      let(:scopes) { 'read' }

      it { expect(last_response.status).to eq 200 }
      it { expect(json_body[:value]).to eq('Access read') }
      it { expect(json_body[:current_user_name]).not_to be_nil }
    end

    context 'returns status for endpoint with specific set of scopes' do
      let(:url) { '/api/v1/status/multiple_scopes' }
      let(:scopes) { 'read,write' }

      it { expect(last_response.status).to eq 200 }
      it { expect(json_body[:value]).to eq('Access read, write') }
      it { expect(json_body[:current_user_name]).not_to be_nil }
    end
  end
end
