module Simple
  module OAuth2
    # UniqToken helper for generation of unique token values
    module UniqToken
      def self.generate(n = 32)
        SecureRandom.hex(n)
      end
    end
  end
end
