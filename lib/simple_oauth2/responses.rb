module Simple
  module OAuth2
    # Processes Rack Responses and contains helper methods
    # Rack::Response to process
    #
    # @return [Array] Rack response
    #
    # @example
    #   response = Simple::OAuth2::Responses.new([200, {}, Rack::BodyProxy.new('200')])
    #
    #   #=> [200, {}, Rack::BodyProxy.new('200')]
    #
    class Responses
      # Simple::OAuth2 response class
      #
      # @param response [Array]
      #   raw Rack::Response object
      #
      def initialize(response)
        @response = response
      end

      # Response status
      def status
        @response[0]
      end

      # Response headers
      def headers
        @response[1]
      end

      # Response JSON-parsed body
      def body
        response_body = @response[2].body.first
        return {} if response_body.nil? || response_body.empty?

        JSON.parse(response_body)
      end
    end
  end
end
