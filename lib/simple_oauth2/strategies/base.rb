module Simple
  module OAuth2
    module Strategies
      # Base Strategies class
      class Base
        class << self
          def authenticate_client(request)
            config.client_class.authenticate(request.client_id)
          end

          def authenticate_resource_owner(client, request)
            config.resource_owner_class.oauth_authenticate(client, request.username, request.password)
          end

          def expose_to_bearer_token(token)
            Rack::OAuth2::AccessToken::Bearer.new(token.to_bearer_token)
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
