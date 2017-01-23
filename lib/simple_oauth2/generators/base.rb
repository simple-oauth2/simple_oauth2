module Simple
  module OAuth2
    module Generators
      # Base class for Simple::OAuth2 generators.
      class Base
        class << self
          # Allowed grant types from the Simple::OAuth2 configuration.
          #
          # @return [Array] allowed grant types.
          #
          def allowed_grants
            config.allowed_grant_types
          end

          # Allowed response types from the Simple::OAuth2 configuration.
          #
          # @return [Array] allowed response types.
          #
          def allowed_types
            config.allowed_response_types
          end

          private

          # Short getter for Simple::OAuth2 configuration.
          def config
            Simple::OAuth2.config
          end

          # Returns Simple::OAuth2 strategy class by type.
          #
          # @param type [Symbol, String] grant_type or response_type value.
          #
          # @return [Password, RefreshToken, AuthorizationCode, ClientCredentials, Code, Token] strategy class.
          #
          def find_strategy(type)
            "Simple::OAuth2::Strategies::#{type.to_s.camelize}".constantize
          end

          # Runs Simple::OAuth2 functionality for Authorization or Token endpoint.
          #
          # @param request [Rack::Request] request object.
          # @param response [Rack::Response] response object.
          #
          def execute(request, response, &_block)
            if block_given?
              yield request, response
            else
              execute_default(request, response)
            end
          end
        end
      end
    end
  end
end
