module Simple
  module OAuth2
    # Simple::OAuth2 strategies namespace
    module Strategies
      # Base Strategies class.
      # Contains common functionality for all the descendants
      class Base
        class << self
          # Authenticates Client from the request
          def authenticate_client(request)
            config.client_class.authenticate(request.client_id)
          end

          # Authenticates Resource Owner from the request
          def authenticate_resource_owner(client, request)
            config.resource_owner_class.oauth_authenticate(client, request.username, request.password)
          end

          # Authenticates Access Grant from the request
          def authenticate_access_grant(request)
            config.access_grant_class.authenticate(request.code)
          end

          # Exposes token object to Bearer token.
          #
          # @param token [#to_bearer_token] any object that responds to `to_bearer_token`
          # @return [Rack::OAuth2::AccessToken::Bearer] bearer token instance
          #
          def expose_to_bearer_token(token)
            Rack::OAuth2::AccessToken::Bearer.new(token.to_bearer_token)
          end

          # Check client for exact matching verifier
          def verify_client!(request)
            client = authenticate_client(request) || request.invalid_client!
            client.secret == request.client_secret || request.invalid_client!
            client
          end

          private

          # Short getter for Simple::OAuth2 configuration.
          def config
            Simple::OAuth2.config
          end
        end
      end
    end
  end
end
