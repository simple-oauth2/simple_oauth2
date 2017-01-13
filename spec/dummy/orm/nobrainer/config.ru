$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'app/twitter'

use Simple::OAuth2.middleware

map '/oauth/token' do
  run Twitter::Token
end

map '/oauth/revoke_token' do
  run Twitter::RevokeToken
end

map '/oauth/authorization' do
  run Twitter::Authorization
end

map '/oauth/custom_token' do
  run Twitter::CustomToken
end

map '/oauth/custom_authorization' do
  run Twitter::CustomAuthorization
end

map '/api/v1/status' do
  run Twitter::Status
end

map '/api/v1/status/single_scope' do
  run Twitter::StatusSingleScope
end

map '/api/v1/status/multiple_scopes' do
  run Twitter::StatusMultipleScopes
end
