class VisualStudio
  module Gem
    module VERSION #:nodoc:
      MAJOR, MINOR, PATCH, PRE = [0, 0, 0, 1]
      STRING = [MAJOR, MINOR, PATCH, PRE].compact.join('.')
    end

    # Returns the semantic version of Visual Studio.
    def self.version
      VisualStudio::Gem::VERSION::STRING
    end
  end
end
