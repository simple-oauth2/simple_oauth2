module Simple
  module OAuth2
    module Generators
      # Base class for Simple::OAuth2 generators
      class Base
        class << self
          # Allowed grant types from the Simple::OAuth2 configuration
          #
          # @return [Array] allowed grant types
          #
          def allowed_grants
            config.allowed_grant_types
          end

          # Allowed response types from the Simple::OAuth2 configuration
          #
          # @return [Array] allowed response types
          #
          def allowed_types
            config.allowed_response_types
          end

          # Short getter for Simple::OAuth2 configuration.
          def config
            Simple::OAuth2.config
          end
        end
      end
    end
  end
end
