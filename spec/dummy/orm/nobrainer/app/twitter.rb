require File.expand_path('../../../../../../lib/simple_oauth2', __FILE__)

require_relative 'models/access_token'
require_relative 'models/access_grant'
require_relative 'models/client'
require_relative 'models/user'

require_relative '../../../endpoints/base'

load File.expand_path('../../../../simple_oauth2_config.rb', __FILE__)

module Twitter
  class API
    extend Twitter::Endpoints::Base
  end
end
