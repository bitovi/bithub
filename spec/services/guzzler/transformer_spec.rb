require 'services/guzzler/spec_helper'
require 'guzzler/transformers/api'
      
class AppendingTransformer
  def initialize(char)
    @char = char
  end

  def call(items)
    items.map { |i| i + @char }
  end
end

class ReversingTransformer
  def call(items)
    items.reverse
  end
end

class SelectiveTransformer
  def initialize(term, length)
    @term = term
    @length = length
  end

  def call(items)
    items.reject{|i| i.length > @length}.reject {|i| i == @term}
  end
end

describe Guzzler::Transformers::Chain do
  describe '#add and #invoke' do
    it 'adds and then sequentially applies transformers' do
      chain = Guzzler::Transformers::Chain.new do |m|
        m.add(SelectiveTransformer, 'go', 3)
        m.add AppendingTransformer, 'x'
        m.add ReversingTransformer
      end
      expect(chain.invoke(%w(foo bar longer go baz))).to eq(%w(bazx barx foox))
    end
  end
end

describe Guzzler::Transformers::Entry do
  describe '#make_new' do
    it 'initializes the Transformer with the provided arguments at run-time' do
      t = Guzzler::Transformers::Entry.new(AppendingTransformer, 'y')
      expect(t.make_new).to be_kind_of(AppendingTransformer)
      expect(t.args).to eq(['y'])
    end
  end
end
