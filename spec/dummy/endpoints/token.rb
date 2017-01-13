module Twitter
  module Endpoints
    module Token
      def call(env)
        response = Simple::OAuth2::Generators::Token.generate_for(env)

        status = response.status
        headers = response.headers
        body = JSON.generate(response.body)

        [status, headers, [body]]
      end
    end

    module RevokeToken
      def call(env)
        params = Rack::Request.new(env).params
        Simple::OAuth2::Generators::Token.revoke(params['token'], env)
      end
    end
  end
end
