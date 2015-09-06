class VisualStudio
  class Name < String
    attr_reader :pretty
    def initialize(name, opts={})
      super(name)
      @pretty = opts[:pretty] || nil
    end
  end
end
