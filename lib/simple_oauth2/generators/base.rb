module Simple
  module OAuth2
    module Generators
      # Base Generators class
      class Base
        class << self
          def allowed_grants
            config.allowed_grant_types
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
