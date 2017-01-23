module Simple
  module OAuth2
    module Strategies
      # ClientCredentials strategy class. Processes request and respond with Access Token.
      #
      # @see https://tools.ietf.org/html/rfc6749#section-4.4
      #
      # The client credentials grant type provides an application a way to access its own service account.
      # Examples of when this might be useful include if an application wants to update its registered description
      # or redirect URI, or access other data stored in its service account via the API.
      #
      # Here is an example POST request to Todo token endpoint:
      #
      # @example
      #   https://api.todo.com/oauth/token?grant_type=client_credentials& # REQUIRED
      #                                    client_id=CLIENT_ID&           # REQUIRED
      #                                    client_secret=CLIENT_SECRET&   # REQUIRED
      #                                    scope=read                     # OPTIONAL
      #
      class ClientCredentials < Base
        class << self
          # Processes ClientCredentials request.
          #
          # @param request [Rack::Request] request object.
          #
          # @return [Rack::OAuth2::AccessToken::Bearer] bearer token instance.
          #
          def process(request)
            client = token_verify_client!(request)

            resource_owner = authenticate_resource_owner(client, request) || request.invalid_grant!

            token = config.access_token_class.create_for(client, resource_owner, scopes_from(request))
            expose_to_bearer_token(token)
          end
        end
      end
    end
  end
end
