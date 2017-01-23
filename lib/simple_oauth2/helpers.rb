module Simple
  module OAuth2
    # Set of Simple::OAuth2 helpers.
    module Helpers
      # Adds OAuth2 AccessToken protection for routes.
      #
      # @param scopes [Array<String, Symbol>] set of scopes required to access the endpoint.
      #
      # @raise [Rack::OAuth2::Server::Resource::Bearer::Unauthorized] invalid AccessToken value.
      # @raise [Rack::OAuth2::Server::Resource::Bearer::Forbidden]
      #   AccessToken expired, revoked or does't have required scopes.
      #
      def access_token_required!(*scopes)
        raise Rack::OAuth2::Server::Resource::Bearer::Unauthorized if current_access_token.nil?
        raise Rack::OAuth2::Server::Resource::Bearer::Forbidden unless valid_access_token?(scopes)
      end

      # Returns ResourceOwner from the AccessToken found by access_token value passed with the request.
      def current_resource_owner
        @current_resource_owner ||= instance_eval(&Simple::OAuth2.config.resource_owner_authenticator)
      end

      # Returns AccessToken instance found by access_token value passed with the request.
      def current_access_token
        @current_access_token ||= request.env[Rack::OAuth2::Server::Resource::ACCESS_TOKEN]
      end

      private

      # Validate current access token not to be expired or revoked and has all the requested scopes.
      #
      # @return [Boolean] true if current_access_token not expired, not revoked and scopes match.
      #
      def valid_access_token?(scopes)
        !current_access_token.revoked? && !current_access_token.expired? &&
          Simple::OAuth2.config.scopes_validator.valid?(current_access_token.scopes, scopes)
      end
    end
  end
end
