module Twitter
  module Endpoints
    module Authorization
      def call(env)
        response = Simple::OAuth2::Generators::Authorization.generate_for(env)

        status = response.status
        headers = response.headers
        body = JSON.generate(response.body)

        [status, headers, [body]]
      end
    end
  end
end
