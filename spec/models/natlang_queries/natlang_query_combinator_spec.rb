require 'spec_helper'
require 'lib/solipsism'
require 'models/natlang_queries/natlang_query_translator'
require 'models/natlang_queries/natlang_query_combinator'


class Dummy
  def self.has_an_attribute?(whatever)
    true
  end
end

describe NatlangQueryCombinator do

  describe "#combine" do
    it 'sequentially combines the queries' do

      nlqs = [
        NatlangQueryTranslator.new(
          double(:natlang_query, :attr => 'title', :op => 'is', :val  => 'canjs'),
          Dummy
        ),
        NatlangQueryTranslator.new(
          double(:natlang_query, :attr => 'content', :op => 'contains', :val  => 'found this error'),
          Dummy
        ),
        NatlangQueryTranslator.new(
          double(:natlang_query, :attr => 'itself', :op => 'tagged_with', :val  => 'canjs,jquerypp'),
          Dummy
        )
      ]

      nlqc = NatlangQueryCombinator.new(nlqs, true)

      expect(nlqc.combine).to eq [
        {:method=>:where, :arg=>["title = ?", "canjs"]},
        {:method=>:basic_search, :arg=>"found this error"},
        {:method=>:tagged_with, :arg=>["canjs", "jquerypp"]}
      ]

    end
  end
end
