require File.expand_path('../../../../../../lib/simple_oauth2', __FILE__)

require_relative 'models/access_token'
require_relative 'models/access_grant'
require_relative 'models/client'
require_relative 'models/user'

require_relative '../../../endpoints/authorization'
require_relative '../../../endpoints/custom_authorization'
require_relative '../../../endpoints/token'
require_relative '../../../endpoints/custom_token'
require_relative '../../../endpoints/status'

load File.expand_path('../config/db.rb', __FILE__)
load File.expand_path('../../../../simple_oauth2_config.rb', __FILE__)

include Simple::OAuth2::Helpers

module Twitter
  class Token
    extend Twitter::Endpoints::Token
  end

  class RevokeToken
    extend Twitter::Endpoints::RevokeToken
  end

  class CustomToken
    extend Twitter::Endpoints::CustomToken
  end

  class Authorization
    extend Twitter::Endpoints::Authorization
  end

  class CustomAuthorization
    extend Twitter::Endpoints::CustomAuthorization
  end

  class Status
    extend Twitter::Endpoints::Status
  end

  class StatusSingleScope
    extend Twitter::Endpoints::StatusSingleScope
  end

  class StatusMultipleScopes
    extend Twitter::Endpoints::StatusMultipleScopes
  end
end
