Simple::OAuth2.configure do |config|
  config.client_class_name = 'Client'
  config.access_token_class_name = 'AccessToken'
  config.resource_owner_class_name = 'User'
  config.access_grant_class_name = 'AccessGrant'

  config.realm = 'Custom Realm'
end
