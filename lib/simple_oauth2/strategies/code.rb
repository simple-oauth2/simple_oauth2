module Simple
  module OAuth2
    module Strategies
      # Code strategy class
      # Processes request and respond with Code
      class Code < Base
        class << self
          # Processes Code request
          def process(request, response)
            client = authorization_verify_client!(request, response)

            authorization_code = config.access_grant_class.create_for(
              client, nil, response.redirect_uri, request.scope.join(',')
            )

            response.code = authorization_code.token
          end
        end
      end
    end
  end
end
