module Simple
  module OAuth2
    module Strategies
      # Resource Owner Password Credentials strategy class. Processes request and respond with Access Token.
      #
      # @see https://tools.ietf.org/html/rfc6749#section-4.3
      #
      # After the user gives their credentials to the application,
      # the application will then request an access token from the authorization server.
      #
      # The POST request might look something like this:
      #
      # @example
      #   https://api.todo.com/oauth/token?grant_type=password&         # REQUIRED
      #                                    username=USERNAME&           # REQUIRED
      #                                    password=PASSWORD&           # REQUIRED
      #                                    client_id=CLIENT_ID&         # REQUIRED
      #                                    client_secret=CLIENT_SECRET& # REQUIRED
      #                                    scope=read                   # OPTIONAL
      class Password < Base
        class << self
          # Processes Password request.
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
