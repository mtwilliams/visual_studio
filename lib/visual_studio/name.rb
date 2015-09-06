module VisualStudio
  class Name < String
    attr_reader :pretty
    def initialize(name, opts={})
      super(name)
      @pretty = opts[:pretty] if opts[:pretty]
    end
  end
end
