module Simple
  module OAuth2
    module Strategies
      # Authorization Code strategy class
      # Processes request and respond with Access Token
      class AuthorizationCode < Base
        class << self
          # Processes Authorization Code request
          def process(request)
            client = verify_client!(request)

            code = authenticate_access_grant(request) || request.invalid_grant!
            code && code.redirect_uri == request.redirect_uri || request.invalid_grant!

            token = config.access_token_class.create_for(client, code.resource_owner, code.scopes)
            expose_to_bearer_token(token)
          end
        end
      end
    end
  end
end
