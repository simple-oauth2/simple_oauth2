module Simple
  module OAuth2
    module Resource
      # OAuth2 middleware Protected Resource Endpoint.
      #
      # @example
      #   # config.ru
      #
      #   use Simple::OAuth2::Resource::Bearer
      #
      class Bearer
        def initialize(app)
          @app = app
        end

        # @see https://github.com/nov/rack-oauth2/wiki/Server-Resource-Endpoint
        def call(env)
          app = Rack::OAuth2::Server::Resource::Bearer.new(@app, Simple::OAuth2.config.realm) do |req|
            Simple::OAuth2.config.token_authenticator.call(req)
          end
          app.call(env)
        end
      end
    end
  end
end
