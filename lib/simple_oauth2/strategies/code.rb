module Simple
  module OAuth2
    module Strategies
      # Code strategy class. Processes request and respond with Code.
      #
      # @see https://tools.ietf.org/html/rfc6749#section-4.1
      #
      # This is a redirection-based flow, which means that the application must be
      # capable of interacting with the user-agent (i.e. the user's web browser)
      # and receiving API authorization codes that are routed through the user-agent.
      #
      # @example
      #   https://api.todo.com/oauth/authorize?response_type=code&        # REQUIRED
      #                                        client_id=CLIENT_ID&       # REQUIRED
      #                                        redirect_uri=CALLBACK_URL& # REQUIRED
      #                                        scope=read                 # OPTIONAL
      #                                        state=zxc                  # RECOMMENDED
      #
      class Code < Base
        class << self
          # Processes Code request.
          #
          # @param request  [Rack::Request] request object.
          # @param response [Rack::Response] response object.
          #
          # @return [String] code token.
          #
          def process(request, response)
            client = authorization_verify_client!(request, response)

            authorization_code = config.access_grant_class.create_for(
              client,
              config.resource_owner_authenticator.call(request),
              response.redirect_uri,
              scopes_from(request)
            )

            response.code = authorization_code.token
          end
        end
      end
    end
  end
end
