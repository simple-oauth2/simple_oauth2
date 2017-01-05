module Simple
  module OAuth2
    # Simple::OAuth2 configuration class
    # Contains default or customized options that would be used in OAuth2 endpoints and helpers
    class Configuration
      include ClassAccessors

      SUPPORTED_GRANT_TYPES = %w(password).freeze
      DEFAULT_TOKEN_LIFETIME = 7200
      DEFAULT_CODE_LIFETIME = 1800
      DEFAULT_REALM = 'OAuth 2.0'.freeze
      DEFAULT_CLIENT_CLASS = 'Client'.freeze
      DEFAULT_ACCESS_TOKEN_CLASS = 'AccessToken'.freeze
      DEFAULT_RESOURCE_OWNER_CLASS = 'User'.freeze
      DEFAULT_ACCESS_GRANT_CLASS = 'AccessGrant'.freeze
      DEFAULT_ISSUE_REFRESH_TOKEN = false

      attr_accessor :access_token_class_name, :access_grant_class_name,
                    :client_class_name, :resource_owner_class_name,
                    :authorization_code_lifetime, :access_token_lifetime,
                    :allowed_grant_types, :realm, :token_generator_class_name,
                    :issue_refresh_token

      def initialize
        setup!
      end

      private

      def setup!
        init_classes

        self.access_token_lifetime = DEFAULT_TOKEN_LIFETIME
        self.authorization_code_lifetime = DEFAULT_CODE_LIFETIME
        self.allowed_grant_types = SUPPORTED_GRANT_TYPES
        self.issue_refresh_token = DEFAULT_ISSUE_REFRESH_TOKEN

        self.realm = DEFAULT_REALM
      end

      def init_classes
        self.token_generator_class_name = Simple::OAuth2::UniqToken.name
        self.access_token_class_name = DEFAULT_ACCESS_TOKEN_CLASS
        self.resource_owner_class_name = DEFAULT_RESOURCE_OWNER_CLASS
        self.client_class_name = DEFAULT_CLIENT_CLASS
        self.access_grant_class_name = DEFAULT_ACCESS_GRANT_CLASS
      end
    end
  end
end
