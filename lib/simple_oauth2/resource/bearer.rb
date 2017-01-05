module Simple
  module OAuth2
    module Resource
      # Middleware for injecting realm and authenticator into Rack OAuth2
      class Bearer
        def initialize(app)
          @app = app
        end

        # see https://github.com/nov/rack-oauth2/blob/master/lib/rack/oauth2/server/resource.rb
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
