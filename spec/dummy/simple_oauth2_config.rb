Simple::OAuth2.configure do |config|
  config.resource_owner_authenticator do |_request|
    User.first
  end

  config.realm = 'Custom Realm'
end
