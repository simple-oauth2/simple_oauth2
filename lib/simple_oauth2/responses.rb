module Simple
  module OAuth2
    # Processes Rack Responses and contains helper methods
    class Responses
      def initialize(response)
        @response = response
      end

      def status
        @response[0]
      end

      def headers
        @response[1]
      end

      def body
        response_body = @response[2].body.first
        return {} if response_body.nil? || response_body.empty?

        JSON.parse(response_body)
      end
    end
  end
end
