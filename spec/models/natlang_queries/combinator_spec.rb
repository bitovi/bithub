require 'spec_helper'
require 'lib/solipsism'
require 'models/natlang_queries/translator'
require 'models/natlang_queries/combinator'

class DummyARClass
  def self.has_an_attribute?(whatever)
    true
  end
end

describe NatlangQueries::Combinator do

  describe "#combine" do
    it 'sequentially combines the queries' do

      nlqs = [
        NatlangQueries::Translator.new(
          double(:natlang_query, attr: 'title', op: 'is', val: 'canjs', negated?: false),
          DummyARClass
        ),
        NatlangQueries::Translator.new(
          double(:natlang_query, attr: 'content', op: 'contains', val: 'found this error', negated?: false),
          DummyARClass
        )
      ]

      nlqc = NatlangQueries::Combinator.new(nlqs)

      expect(nlqc.combine).to eq [
        {:method=>:where, :arg=>["title = ?", "canjs"]},
        {:method=>:basic_search, :arg=>"found this error"}
      ]

    end
  end
end
