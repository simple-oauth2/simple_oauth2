module Simple
  module OAuth2
    # Processes Rack Responses and contains helper methods
    #
    # @return [Object] Rack response
    #
    # @example
    #   rack_response = [
    #     200,
    #     { 'Content-Type' => 'application/json' },
    #     Rack::BodyProxy.new(Rack::Response.new('200'.to_json))
    #   ]
    #   response = Simple::OAuth2::Responses.new(rack_response)
    #
    #   response.status  #=> 200
    #   response.headers #=> {}
    #   response.body    #=> '200'
    #   response         #=> <Simple::OAuth2::Responses:0x007fc9f32080b8 @response=[
    #     200,
    #     {},
    #     <Rack::BodyProxy:0x007fc9f3208108
    #       @block=nil,
    #       @body= <Rack::Response:0x007fc9f3208388
    #         @block=nil,
    #         @body=["\"200\""],
    #         @header={"Content-Length"=>"5"},
    #         @length=5,
    #         @status=200
    #       >,
    #       @closed=false
    #     >
    #   ]
    #
    class Responses
      # Simple::OAuth2 response class
      #
      # @param response [Array] raw Rack::Response object
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
