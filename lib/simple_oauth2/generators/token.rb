module Simple
  module OAuth2
    module Generators
      # Token generator class
      # Processes the request by required Grant Type and builds the response
      class Token < Base
        class << self
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

          private

          def execute_default(request, response)
            strategy = find_strategy(request.grant_type) || request.invalid_grant!
            response.access_token = strategy.process(request)
          end

          def find_strategy(grant_type)
            "Simple::OAuth2::Strategies::#{grant_type.to_s.classify}".constantize
          end
        end
      end
    end
  end
end
