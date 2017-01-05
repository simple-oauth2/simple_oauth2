require 'spec_helper'

describe 'GET Protected Resources' do
  subject { -> { get url, params } }

  let(:url) { '/api/v1/status' }
  let(:access_token) { AccessToken.create(attributes_for(:access_token)) }
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
      let(:access_token) { AccessToken.create(attributes_for(:access_token_with_read_scopes)) }
      let(:url) { '/api/v1/status/multiple_scopes' }

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
      let(:access_token) { AccessToken.create(attributes_for(:access_token_with_read_scopes)) }
      let(:url) { '/api/v1/status/single_scope' }

      it { expect(last_response.status).to eq 200 }
      it { expect(json_body[:value]).to eq('Access read') }
      it { expect(json_body[:current_user_name]).not_to be_nil }
    end

    context 'returns status for endpoint with specific set of scopes' do
      let(:access_token) { AccessToken.create(attributes_for(:access_token_with_read_and_write_scopes)) }
      let(:url) { '/api/v1/status/multiple_scopes' }

      it { expect(last_response.status).to eq 200 }
      it { expect(json_body[:value]).to eq('Access read, write') }
      it { expect(json_body[:current_user_name]).not_to be_nil }
    end
  end
end
