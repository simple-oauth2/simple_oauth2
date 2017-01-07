module Simple
  module OAuth2
    module Generators
      # Authorization generator class
      # Processes the request by required Response Type and builds the response
      class Authorization < Base
        class << self
          # Generates Authorization Response based on the request
          #
          # @return [Simple::OAuth2::Responses] response
          #
          def generate_for(env, &_block)
            authorization = Rack::OAuth2::Server::Authorize.new do |request, response|
              request.unsupported_response_type! unless allowed_types.include?(request.response_type.to_s)

              if block_given?
                yield request, response
              else
                execute_default(request, response)
              end
            end

            Simple::OAuth2::Responses.new(authorization.call(env))
          rescue Rack::OAuth2::Server::Authorize::BadRequest => error
            error_response(error)
          end

          private

          # Returns error Rack::Response
          def error_response(error)
            response = Rack::Response.new
            response.status = error.status
            response.header['Content-Type'] = 'application/json'
            response.write(JSON.dump(Rack::OAuth2::Util.compact_hash(error.protocol_params)))

            Simple::OAuth2::Responses.new(response.finish)
          end

          # Runs default Simple::OAuth2 functionality for Authorization endpoint
          #
          # @param request [Rack::Request] request object
          # @param response [Rack::Response] response object
          #
          def execute_default(request, response)
            find_strategy(request.response_type).process(request, response)
          end

          # Returns Simple::OAuth2 strategy class by Response Type
          #
          # @param response_type [Symbol] response type value
          #
          # @return [Code] strategy class
          #
          def find_strategy(response_type)
            "Simple::OAuth2::Strategies::#{response_type.to_s.classify}".constantize
          end
        end
      end
    end
  end
end
