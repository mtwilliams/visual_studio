class VisualStudio
  module VERSION #:nodoc:
    MAJOR, MINOR, PATCH, PRE = [0, 0, 0, 3]
    STRING = [MAJOR, MINOR, PATCH, PRE].compact.join('.')
  end

  # Returns the semantic version of `visual_studio`.
  def self.version
    VisualStudio::VERSION::STRING
  end
end
