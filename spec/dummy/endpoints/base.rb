module Twitter
  module Endpoints
    module Base
      def call(env)
        # if env['REQUEST_METHOD'] == 'POST' && env['PATH_INFO'] == '/oauth/token'
        response = Simple::OAuth2::Generators::Token.generate_for(env)

        status = response.status
        headers = response.headers
        body = JSON.generate(response.body)

        [status, headers, [body]]
      end
    end
  end
end
