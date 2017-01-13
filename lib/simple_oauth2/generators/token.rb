module Simple
  module OAuth2
    module Generators
      # Token generator class.
      # Processes the request by required Grant Type and builds the response
      class Token < Base
        class << self
          # Generates Token Response based on the request
          #
          # @return [Simple::OAuth2::Responses] response
          #
          def generate_for(env, &_block)
            token = Rack::OAuth2::Server::Token.new do |request, response|
              request.unsupported_grant_type! unless allowed_grants.include?(request.grant_type.to_s)

              if block_given?
                yield(request, response)
              else
                execute_default(request, response)
              end
            end

            Simple::OAuth2::Responses.new(token.call(env))
          end

          # OAuth 2.0 Token Revocation - http://tools.ietf.org/html/rfc7009
          #
          # @return [Response] with HTTP status code 200
          #
          def revoke(token, env)
            access_token = config.access_token_class.authenticate(token, 'refresh_token')

            if access_token
              request = Rack::OAuth2::Server::Token::Request.new(env)

              # The authorization server, if applicable, first authenticates the client
              # and checks its ownership of the provided token.
              client = Simple::OAuth2::Strategies::Base.authenticate_client(request) || request.invalid_client!
              client.id == access_token.client.id && access_token.revoke!
            end
            # The authorization server responds with HTTP status code 200 if the token
            # has been revoked successfully or if the client submitted an invalid token
            [200, {}, []]
          end

          private

          # Runs default Simple::OAuth2 functionality for Token endpoint.
          #
          # @param request [Rack::Request] request object
          # @param response [Rack::Response] response object
          #
          def execute_default(request, response)
            strategy = find_strategy(request.grant_type) || request.invalid_grant!
            response.access_token = strategy.process(request)
          end

          # Returns Simple::OAuth2 strategy class by Grant Type
          #
          # @param grant_type [Symbol] grant type value
          #
          # @return [Password, RefreshToken, AuthorizationCode] strategy class
          #
          def find_strategy(grant_type)
            "Simple::OAuth2::Strategies::#{grant_type.to_s.classify}".constantize
          end
        end
      end
    end
  end
end
