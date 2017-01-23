module Simple
  module OAuth2
    module Strategies
      # Authorization Code strategy class. Processes request and respond with Access Token.
      #
      # @see https://tools.ietf.org/html/rfc6749#section-4.1.3
      #
      # The application requests an access token from the API,
      # by passing the authorization code along with authentication details,
      # including the client secret, to the API token endpoint.
      #
      # Here is an example POST request to Todo token endpoint:
      #
      # @example
      #   https://api.todo.com/oauth/token?client_id=CLIENT_ID&           # REQUIRED
      #                                    client_secret=CLIENT_SECRET&   # REQUIRED
      #                                    grant_type=authorization_code& # REQUIRED
      #                                    code=AUTHORIZATION_CODE&       # REQUIRED
      #                                    redirect_uri=CALLBACK_URL      # REQUIRED
      #
      class AuthorizationCode < Base
        class << self
          # Processes Authorization Code request.
          #
          # @param request [Rack::Request] request object.
          #
          # @return [Rack::OAuth2::AccessToken::Bearer] bearer token instance.
          #
          def process(request)
            client = token_verify_client!(request)

            code = authenticate_access_grant(request) || request.invalid_grant!
            code.redirect_uri == request.redirect_uri || request.invalid_grant!

            token = config.access_token_class.create_for(client, code.resource_owner, code.scopes)
            expose_to_bearer_token(token)
          end
        end
      end
    end
  end
end
