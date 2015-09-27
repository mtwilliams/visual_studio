module VisualStudio
  module Helpers
    class PrettyString < String
      attr_reader :pretty
      def initialize(name, opts={})
        super(name)
        @pretty = opts[:pretty] if opts.include? :pretty
      end
    end
  end
end
