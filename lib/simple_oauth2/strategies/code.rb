module Simple
  module OAuth2
    module Strategies
      # Code strategy class
      # Processes request and respond with Code
      class Code < Base
        class << self
          # Processes Code request
          def process(request, response)
            client = authenticate_client(request) || request.bad_request!
            response.redirect_uri = request.verify_redirect_uri!(client.redirect_uri)

            authorization_code = config.access_grant_class.create_for(
              client, nil, response.redirect_uri, request.scope.join(',')
            )

            response.code = authorization_code.token
            response.approve!
            response
          end
        end
      end
    end
  end
end
