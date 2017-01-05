module Simple
  module OAuth2
    # UniqToken helper for generation of unique token values.
    # Can process custom option
    module UniqToken
      # Generates unique token value
      #
      # @param n [Integer] specifies the length of the random length
      #
      # @return [String] unique token value
      #
      def self.generate(n = 32)
        SecureRandom.hex(n)
      end
    end
  end
end
