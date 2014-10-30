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
          double(:natlang_query, :attr => 'title', :op => 'is', :val  => 'canjs'),
          DummyARClass
        ),
        NatlangQueries::Translator.new(
          double(:natlang_query, :attr => 'content', :op => 'contains', :val  => 'found this error'),
          DummyARClass
        ),
        NatlangQueries::Translator.new(
          double(:natlang_query, :attr => 'itself', :op => 'tagged_with', :val  => 'canjs,jquerypp'),
          DummyARClass
        )
      ]

      nlqc = NatlangQueries::Combinator.new(nlqs, true)

      expect(nlqc.combine).to eq [
        {:method=>:where, :arg=>["title = ?", "canjs"]},
        {:method=>:basic_search, :arg=>"found this error"},
        {:method=>:tagged_with, :arg=>["canjs", "jquerypp"]}
      ]

    end
  end
end
