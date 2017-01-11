module Simple
  module OAuth2
    module Strategies
      # Refresh Token strategy class
      # Processes request and respond with Access Token
      class RefreshToken < Base
        class << self
          # Processes Refresh Token request
          def process(request)
            client = token_verify_client!(request)
            refresh_token = verify_refresh_token!(request, client.id)

            token = config.access_token_class.create_for(
              client, refresh_token.resource_owner, request.scope.join(',')
            )
            run_callback_on_refresh_token(refresh_token) if config.on_refresh_runnable?

            expose_to_bearer_token(token)
          end

          private

          # Check refresh token and client id for exact matching verifier
          def verify_refresh_token!(request, client_id)
            refresh_token = config.access_token_class.authenticate(request.refresh_token, 'refresh_token')
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
              raise(ArgumentError, I18n.t('simple_oauth2.errors.messages.on_refresh', callback: callback))
            end
          end
        end
      end
    end
  end
end
