$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'app/twitter'

use Simple::OAuth2.middleware

map '/oauth/token' do
  run Twitter::Token
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
