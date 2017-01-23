module Simple
  module OAuth2
    module Strategies
      # Token strategy class. Processes request and respond with Access Token.
      #
      # @see https://tools.ietf.org/html/rfc6749#section-4.2
      #
      # The implicit grant type is used for mobile apps and web applications
      # (i.e. applications that run in a web browser), where the client secret confidentiality
      # is not guaranteed. The implicit grant type is also a redirection-based
      # flow but the access token is given to the user-agent to forward to the application,
      # so it may be exposed to the user and other applications on the user's device.
      # Also, this flow does not authenticate the identity of the application,
      # and relies on the redirect URI (that was registered with the service) to serve this purpose.
      #
      # @example
      #   https://api.todo.com/oauth/authorize?response_type=token&       # REQUIRED
      #                                        client_id=CLIENT_ID&       # REQUIRED
      #                                        redirect_uri=CALLBACK_URL& # REQUIRED
      #                                        scope=read&                # OPTIONAL
      #                                        state=zxc                  # RECOMMENDED
      #
      class Token < Base
        class << self
          # Processes Token request.
          #
          # @param request  [Rack::Request] request object.
          # @param response [Rack::Response] response object.
          #
          # @return [String] code token.
          #
          def process(request, response)
            client = authorization_verify_client!(request, response)

            access_token = config.access_token_class.create_for(
              client,
              config.resource_owner_authenticator.call(request),
              scopes_from(request)
            )

            response.access_token = expose_to_bearer_token(access_token)
          end
        end
      end
    end
  end
end
