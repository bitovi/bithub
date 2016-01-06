module Guzzler::Transformers
  class Entry
    attr_reader :klass

    def initialize(klass, *args)
      @klass = klass
      @args = args
    end
    attr_reader :args

    def make_new
      @klass.new(*@args)
    end
  end
end
