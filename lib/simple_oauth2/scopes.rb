module Simple
  module OAuth2
    # Scopes helper for scopes validation
    class Scopes
      def self.valid?(scopes, access_scopes)
        new(scopes, access_scopes).valid?
      end

      def initialize(access_scopes, scopes = [])
        @scopes = to_array(scopes)
        @access_scopes = to_array(access_scopes)
      end

      def valid?
        @scopes.empty? || present_in_access_token?
      end

      private

      def present_in_access_token?
        Set.new(@access_scopes) >= Set.new(@scopes)
      end

      def to_array(scopes)
        collection = if scopes.is_a?(Array) || scopes.respond_to?(:to_a)
                       scopes.to_a
                     elsif scopes.is_a?(String)
                       scopes.split(',')
                     else
                       raise ArgumentError, 'scopes class is not supported!'
                     end

        collection.map(&:to_s)
      end
    end
  end
end
