module Simple
  module OAuth2
    # Simple::OAuth2 default constants
    module Constants
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
    end
  end
end
