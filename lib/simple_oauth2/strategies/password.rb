module Simple
  module OAuth2
    module Strategies
      # Resource Owner Password Credentials strategy class
      # Processes request and respond with Access Token
      class Password < Base
        class << self
          # Processes Password request
          def process(request)
            client = authenticate_client(request) || request.invalid_client!
            client.secret == request.client_secret || request.invalid_client!

            resource_owner = authenticate_resource_owner(client, request) || request.invalid_grant!

            token = config.access_token_class.create_for(client, resource_owner, request.scope.join(','))
            expose_to_bearer_token(token)
          end
        end
      end
    end
  end
end
