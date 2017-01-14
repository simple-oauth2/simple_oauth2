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
          # @param token [AccessToken] any object that responds to `to_bearer_token`
          # @return [Rack::OAuth2::AccessToken::Bearer] bearer token instance
          #
          def expose_to_bearer_token(token)
            Rack::OAuth2::AccessToken::Bearer.new(token.to_bearer_token)
          end

          # Token endpoint, check client for exact matching verifier
          def token_verify_client!(request)
            client = authenticate_client(request) || request.invalid_client!
            client.secret == request.client_secret || request.invalid_client!
            client
          end

          # Authorization endpoint, check client and redirect_uri for exact matching verifier
          def authorization_verify_client!(request, response)
            client = authenticate_client(request) || request.bad_request!
            response.redirect_uri = request.verify_redirect_uri!(client.redirect_uri)
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
