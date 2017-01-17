module Simple
  # Semantic versioning
  module OAuth2
    # Simple::OAuth2 version
    # @return [Gem::Version] version of the gem
    #
    def self.gem_version
      Gem::Version.new VERSION::STRING
    end

    # Simple::OAuth2 semantic versioning module
    # Contains detailed info about gem version
    module VERSION
      # Level changes for implementation level detail changes, such as small bug fixes
      PATCH = 0
      # Level changes for any backwards compatible API changes, such as new functionality/features
      MINOR = 0
      # Level changes for backwards incompatible API changes,
      # such as changes that will break existing users code if they update
      MAJOR = 0

      # Full gem version string
      STRING = [MAJOR, MINOR, PATCH].join('.')
    end
  end
end
