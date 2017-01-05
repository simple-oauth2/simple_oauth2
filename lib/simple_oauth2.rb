require 'rack/oauth2'

require 'simple_oauth2/configuration/class_accessors'
require 'simple_oauth2/configuration'
require 'simple_oauth2/scopes'
require 'simple_oauth2/uniq_token'

if defined?(NoBrainer::Document)
  require 'simple_oauth2/mixins/nobrainer/access_token'
  require 'simple_oauth2/mixins/nobrainer/access_grant'
  require 'simple_oauth2/mixins/nobrainer/client'
end

require 'simple_oauth2/strategies/base'
require 'simple_oauth2/strategies/password'

require 'simple_oauth2/generators/base'
require 'simple_oauth2/generators/token'

require 'simple_oauth2/helpers'

require 'simple_oauth2/responses'

# Simple namespace for the gem
module Simple
  # Main Simple::OAuth2 module
  module OAuth2
    class << self
      def config
        @config ||= Simple::OAuth2::Configuration.new
      end

      def configure
        yield config if block_given?
      end
    end
  end
end
