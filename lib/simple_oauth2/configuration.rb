module Simple
  module OAuth2
    # Simple::OAuth2 configuration class
    # Contains default or customized options that would be used in OAuth2 endpoints and helpers
    class Configuration
      include ClassAccessors

      # Currently supported (by the gem) OAuth2 grant types
      SUPPORTED_GRANT_TYPES = %w(password authorization_code refresh_token).freeze

      # Default OAuth2 response types
      SUPPORTED_RESPONSE_TYPES = %w(code token).freeze

      # Default Access Token TTL (in seconds)
      DEFAULT_TOKEN_LIFETIME = 7200

      # Default Authorization Code TTL (in seconds)
      DEFAULT_CODE_LIFETIME = 1800

      # Default realm value
      DEFAULT_REALM = 'OAuth 2.0'.freeze

      # Default Client class value
      DEFAULT_CLIENT_CLASS = 'Client'.freeze

      # Default Access Token class value
      DEFAULT_ACCESS_TOKEN_CLASS = 'AccessToken'.freeze

      # Default Resource Owner class value
      DEFAULT_RESOURCE_OWNER_CLASS = 'User'.freeze

      # Default Access Grant class value
      DEFAULT_ACCESS_GRANT_CLASS = 'AccessGrant'.freeze

      # Default option for generate refresh token
      DEFAULT_ISSUE_REFRESH_TOKEN = false

      # The names of the classes that represents OAuth2 roles
      #
      # @return [String] class name
      #
      attr_accessor :access_token_class_name, :access_grant_class_name,
                    :client_class_name, :resource_owner_class_name

      # Class name for the OAuth2 helper class that generates unique token values
      #
      # @return [String] token generator class name
      #
      attr_accessor :token_generator_class_name

      # Class name for the OAuth2 helper class that validates requested scopes against Access Token scopes
      #
      # @return [String] scope validator class name
      #
      attr_accessor :scopes_validator_class_name

      # Access Token and Authorization Code lifetime in seconds
      #
      # @return [Integer] lifetime in seconds
      #
      attr_accessor :authorization_code_lifetime, :access_token_lifetime

      # OAuth2 grant types (flows) allowed to be processed
      #
      # @return [Array<String>] grant types
      #
      attr_accessor :allowed_grant_types

      # OAuth2 response types (flows) allowed to be processed
      #
      # @return [Array<String>] response types
      #
      attr_accessor :allowed_response_types

      # Realm value
      #
      # @return [String] realm
      #
      attr_accessor :realm

      # Access Token authenticator block option for customization
      attr_accessor :token_authenticator

      # Specifies whether to generate a Refresh Token when creating an Access Token
      #
      # @return [Boolean] true if need to generate refresh token
      #
      attr_accessor :issue_refresh_token

      # Callback that would be invoked during processing of Refresh Token request for
      # the original Access Token found by token value
      attr_accessor :on_refresh

      # Return a new instance of Configuration with default options
      def initialize
        setup!
      end

      # Accessor for Access Token authenticator block. Set it to proc
      # if called with block or returns current value of the accessor.
      def token_authenticator(&block)
        if block_given?
          instance_variable_set(:'@token_authenticator', block)
        else
          instance_variable_get(:'@token_authenticator')
        end
      end

      # Indicates if on_refresh callback can be invoked.
      #
      # @return [Boolean]
      #   true if callback can be invoked and false in other cases
      #
      def on_refresh_runnable?
        !on_refresh.nil? && on_refresh != :nothing
      end

      # Accessor for on_refresh callback. Set callback proc
      # if called with block or returns current value of the accessor.
      def on_refresh(&block)
        if block_given?
          instance_variable_set(:'@on_refresh', block)
        else
          instance_variable_get(:'@on_refresh')
        end
      end

      private

      # Setup configuration to default options values
      def setup!
        init_classes
        init_authenticators
        init_represents_roles

        self.access_token_lifetime = DEFAULT_TOKEN_LIFETIME
        self.authorization_code_lifetime = DEFAULT_CODE_LIFETIME
        self.allowed_grant_types = SUPPORTED_GRANT_TYPES
        self.allowed_response_types = SUPPORTED_RESPONSE_TYPES
        self.issue_refresh_token = DEFAULT_ISSUE_REFRESH_TOKEN
        self.on_refresh = :nothing

        self.realm = DEFAULT_REALM
      end

      # Sets OAuth2 helpers classes to gem defaults
      def init_classes
        self.token_generator_class_name = Simple::OAuth2::UniqToken.name
        self.scopes_validator_class_name = Simple::OAuth2::Scopes.name
      end

      # Sets authenticators to gem defaults.
      def init_authenticators
        self.token_authenticator = default_token_authenticator
      end

      # Sets OAuth2 represents roles
      def init_represents_roles
        self.access_token_class_name = DEFAULT_ACCESS_TOKEN_CLASS
        self.resource_owner_class_name = DEFAULT_RESOURCE_OWNER_CLASS
        self.client_class_name = DEFAULT_CLIENT_CLASS
        self.access_grant_class_name = DEFAULT_ACCESS_GRANT_CLASS
      end

      # Default Access Token authenticator block.
      # Validates token value passed with the request params
      def default_token_authenticator
        lambda do |request|
          access_token_class.authenticate(request.access_token) || request.invalid_token!
        end
      end
    end
  end
end
