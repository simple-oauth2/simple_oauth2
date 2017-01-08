module Twitter
  module Endpoints
    module CustomAuthorization
      def request
        @request
      end

      def call(env)
        @request = Rack::Request.new(env)

        response = Simple::OAuth2::Generators::Authorization.generate_for(env, &:unsupported_response_type!)

        status = response.status
        headers = response.headers
        body = JSON.generate(response.body)

        [status, headers, [body]]
      end
    end
  end
end
