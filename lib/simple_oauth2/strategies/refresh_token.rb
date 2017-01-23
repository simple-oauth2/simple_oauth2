module Simple
  module OAuth2
    module Strategies
      # Refresh Token strategy class. Processes request and respond with Access Token.
      #
      # @see https://tools.ietf.org/html/rfc6749#section-6
      #
      # After an access token expires, using it to make a request from the API
      # will result in an "Invalid Token Error". At this point,
      # if a refresh token was included when the original access token was issued,
      # it can be used to request a fresh access token from the authorization server.
      #
      # Here is an example POST request, using a refresh token to obtain a new access token:
      #
      # @example
      #   https://api.todo.com/oauth/token?grant_type=refresh_token&    # REQUIRED
      #                                    client_id=CLIENT_ID&         # REQUIRED
      #                                    client_secret=CLIENT_SECRET& # REQUIRED
      #                                    refresh_token=REFRESH_TOKEN& # REQUIRED
      #                                    scope=read                   # OPTIONAL
      #
      class RefreshToken < Base
        class << self
          # Processes Refresh Token request.
          #
          # @param request [Rack::Request] request object.
          #
          # @return [Rack::OAuth2::AccessToken::Bearer] bearer token instance.
          #
          def process(request)
            client = token_verify_client!(request)
            refresh_token = verify_refresh_token!(request, client.id)

            token = config.access_token_class.create_for(
              client, refresh_token.resource_owner, scopes_from(request)
            )
            run_callback_on_refresh_token(refresh_token) if config.on_refresh_runnable?

            expose_to_bearer_token(token)
          end

          private

          # Check refresh token and client id for exact matching verifier
          def verify_refresh_token!(request, client_id)
            refresh_token = config.access_token_class.by_refresh_token(request.refresh_token)
            refresh_token || request.invalid_grant!
            refresh_token.client_id == client_id || request.unauthorized_client!

            refresh_token
          end

          # Invokes custom callback on Access Token refresh.
          # If callback is a proc, then call it with token.
          # If access token responds to callback value (symbol for example), then call it from the token.
          #
          # @param access_token [Object] Access Token instance
          #
          def run_callback_on_refresh_token(access_token)
            callback = config.on_refresh

            if callback.respond_to?(:call)
              callback.call(access_token)
            elsif access_token.respond_to?(callback)
              access_token.send(callback)
            else
              raise(ArgumentError, ":on_refresh is not a block and Access Token class doesn't respond to #{callback}!")
            end
          end
        end
      end
    end
  end
end
