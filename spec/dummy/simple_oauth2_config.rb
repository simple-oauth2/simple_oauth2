Simple::OAuth2.configure do |config|
  config.resource_owner_authenticator do |_request|
    User.first
  end

  config.server_abstract_request do
    request
  end

  config.realm = 'Custom Realm'
end
