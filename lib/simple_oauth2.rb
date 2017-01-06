require 'rack/oauth2'

require 'simple_oauth2/configuration/class_accessors'
require 'simple_oauth2/configuration'
require 'simple_oauth2/scopes'
require 'simple_oauth2/uniq_token'
require 'simple_oauth2/resource/bearer'

# Mixins
if defined?(NoBrainer::Document)
  require 'simple_oauth2/mixins/nobrainer/access_token'
  require 'simple_oauth2/mixins/nobrainer/access_grant'
  require 'simple_oauth2/mixins/nobrainer/client'
end

# Authorization Grants aka Flows (Strategies)
require 'simple_oauth2/strategies/base'
require 'simple_oauth2/strategies/password'
require 'simple_oauth2/strategies/authorization_code'

# Generators
require 'simple_oauth2/generators/base'
require 'simple_oauth2/generators/token'

# Helpers
require 'simple_oauth2/helpers'

# Responses
require 'simple_oauth2/responses'

# Simple namespace for the gem
module Simple
  # Main Simple::OAuth2 module
  module OAuth2
    class << self
      # Simple::OAuth2 configuration
      #
      # @return [Simple::OAuth2::Configuration] configuration object with default values
      #
      def config
        @config ||= Simple::OAuth2::Configuration.new
      end

      # Configures Simple::OAuth2.
      # Yields Simple::OAuth2::Configuration instance to the block
      def configure
        yield config if block_given?
      end

      # Simple::OAuth2 default middleware
      def middleware
        Simple::OAuth2::Resource::Bearer
      end
    end
  end
end
