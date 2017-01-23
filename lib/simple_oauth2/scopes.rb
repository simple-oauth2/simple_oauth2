module Simple
  module OAuth2
    # Scopes helper for scopes validation.
    class Scopes
      # Checks if requested scopes are valid.
      #
      # @param access_scopes [Array] scopes of AccessToken class.
      # @param scopes [Array<String, Symbol>] array, symbol, string of any object that responds to `to_a`.
      #
      # @return [Boolean] true if scopes match.
      #
      def self.valid?(access_scopes, scopes)
        new(access_scopes, scopes).valid?
      end

      # Helper class initializer.
      #
      # @param access_scopes [Array] scopes of AccessToken class.
      # @param scopes [Array<String, Symbol>] array, symbol, string of any object that responds to `to_a`.
      #
      def initialize(access_scopes, scopes = [])
        @scopes = to_array(scopes)
        @access_scopes = to_array(access_scopes)
      end

      # Checks if requested scopes (passed and processed on initialization) are presented in the AccessToken.
      #
      # @return [Boolean] true if requested scopes are empty or present in access_scopes.
      #
      def valid?
        @scopes.empty? || present_in_access_token?
      end

      private

      # Checks if scopes present in access_scopes.
      #
      # @return [Boolean] true if requested scopes present in access_scopes.
      #
      def present_in_access_token?
        Set.new(@access_scopes) >= Set.new(@scopes)
      end

      # Converts scopes set to the array.
      #
      # @param scopes [Array<String, Symbol>, #to_a]
      #   string, symbol, array or object that responds to `to_a`.
      # @return [Array<String>] array of scopes.
      #
      def to_array(scopes)
        collection = if scopes.is_a?(Array) || scopes.respond_to?(:to_a)
                       scopes.to_a
                     elsif scopes.is_a?(String) || scopes.is_a?(Symbol)
                       scopes.split
                     end

        collection.map(&:to_s)
      end
    end
  end
end
