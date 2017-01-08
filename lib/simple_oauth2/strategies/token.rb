module Simple
  module OAuth2
    module Strategies
      # Token strategy class
      # Processes request and respond with Code
      class Token < Base
        class << self
          # Processes Token request
          def process(request, response)
            client = authorization_verify_client!(request, response)

            access_token = config.access_token_class.create_for(client, nil, request.scope.join(','))

            response.access_token = expose_to_bearer_token(access_token)
          end
        end
      end
    end
  end
end
