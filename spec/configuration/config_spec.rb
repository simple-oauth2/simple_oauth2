require 'spec_helper'

describe Simple::OAuth2::Configuration do
  let(:config) { described_class.new }

  class CustomClient
    def self.authenticate(_key, _secret = nil)
      'Test'
    end
  end

  class CustomAccessToken
    def self.create_for(_client, _resource_owner, _scopes = nil); end

    def self.authenticate(_token, _type = nil)
      'Test'
    end

    def client; end

    def resource_owner; end

    def expired?; end

    def revoked?; end

    def revoke!(_revoked_at = Time.now); end

    def to_bearer_token; end
  end

  class CustomResourceOwner
    def self.oauth_authenticate(_client, _username, _password)
      'Test'
    end
  end

  context 'default config' do
    it { expect(config.access_token_lifetime).to eq(7200) }
    it { expect(config.authorization_code_lifetime).to eq(1800) }

    it { expect(config.realm).to eq(Simple::OAuth2::Configuration::DEFAULT_REALM) }
    it { expect(config.allowed_grant_types).to eq(%w(password authorization_code refresh_token)) }

    it { expect(config.issue_refresh_token).to be_falsey }
    it { expect(config.on_refresh).to eq(:nothing) }

    it { expect(config.scopes_validator_class_name).to eq(Simple::OAuth2::Scopes.name) }
  end

  context 'custom config' do
    class CustomScopesValidator
      def self.valid?(_access_token, _scopes)
        false
      end
    end

    class CustomTokenGenerator
      def self.generate(number = nil)
        if number
          'custom_token'
        else
          'default_token'
        end
      end
    end

    before do
      config.access_token_class_name = 'CustomAccessToken'
      config.resource_owner_class_name = 'CustomResourceOwner'
      config.client_class_name = 'CustomClient'
      config.access_grant_class_name = 'Object'
      config.scopes_validator_class_name = 'CustomScopesValidator'
    end

    after do
      config.access_token_class_name = 'AccessToken'
      config.resource_owner_class_name = 'ResourceOwner'
      config.client_class_name = 'Client'
      config.access_grant_class_name = 'AccessGrant'
      config.scopes_validator_class_name = 'ScopesValidator'
    end

    context 'works with custom token generator' do
      before do
        Simple::OAuth2.configure do |c|
          c.token_generator_class_name = 'CustomTokenGenerator'
        end
      end

      after do
        Simple::OAuth2.configure do |c|
          c.token_generator_class_name = Simple::OAuth2::UniqToken.name
        end
      end

      it { expect(Simple::OAuth2.config.token_generator.generate).to eq('default_token') }
      it { expect(Simple::OAuth2.config.token_generator.generate(15)).to eq('custom_token') }
    end

    context 'invokes custom scopes validator' do
      it { expect(config.scopes_validator.valid?(nil, nil)).to be_falsey }
    end

    context 'works with custom Access Token class' do
      it { expect(config.access_token_class.authenticate('')).to eq('Test') }
    end

    context 'works with custom Client class' do
      it { expect(config.client_class.authenticate('')).to eq('Test') }
    end

    context 'works with custom Resource Owner class' do
      it { expect(config.resource_owner_class.oauth_authenticate('', '', '')).to eq('Test') }
    end

    context 'works with custom token authenticator' do
      before do
        Simple::OAuth2.configure do |c|
          c.token_authenticator do
            raise ArgumentError, 'Test'
          end
        end
      end

      after do
        Simple::OAuth2.configure do |c|
          c.token_authenticator = config.default_token_authenticator
        end
      end

      it { expect { config.token_authenticator.call }.to raise_error(ArgumentError) }
    end

    context 'works with custom on_refresh callback' do
      let(:token) { AccessToken.create }

      before do
        Simple::OAuth2.configure do |c|
          c.on_refresh do |access_token|
            access_token.update(scopes: 'test')
          end
        end
      end

      after(:all) do
        Simple::OAuth2.configure do |c|
          c.on_refresh = :nothing
        end
      end

      it do
        expect { Simple::OAuth2::Strategies::RefreshToken.send(:run_callback_on_refresh_token, token) }
          .to change { token.scopes }.to('test')
      end
    end

    context 'raises an error with invalid on_refresh callback' do
      before do
        Simple::OAuth2.configure do |c|
          c.on_refresh = 'invalid'
        end
      end

      after(:all) do
        Simple::OAuth2.configure do |c|
          c.on_refresh = :nothing
        end
      end

      it do
        expect { Simple::OAuth2::Strategies::RefreshToken.send(:run_callback_on_refresh_token, nil) }
          .to raise_error(ArgumentError)
      end
    end
  end
end
