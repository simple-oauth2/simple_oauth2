module Simple
  module OAuth2
    # Set OAuth2 helpers
    module Helpers
      def access_token_required!(*scopes)
        raise Rack::OAuth2::Server::Resource::Bearer::Unauthorized if current_access_token.nil?
        raise Rack::OAuth2::Server::Resource::Bearer::Forbidden unless valid_access_token?(scopes)
      end

      def current_resource_owner
        @current_resource_owner ||= current_access_token.resource_owner
      end

      def current_access_token
        @current_access_token ||= request.env[Rack::OAuth2::Server::Resource::ACCESS_TOKEN]
      end

      private

      def valid_access_token?(scopes)
        !current_access_token.revoked? && !current_access_token.expired? &&
          Simple::OAuth2::Scopes.valid?(current_access_token.scopes, scopes)
      end
    end
  end
end
