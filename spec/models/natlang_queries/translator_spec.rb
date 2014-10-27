require 'spec_helper'
require 'models/natlang_queries/translator'

class DummyARClass
  def self.has_an_attribute?(whatever)
    true
  end
end

RSpec.describe NatlangQueries::Translator, :type => :model do

  describe '#verb' do
    it 'transforms the "contains" operator to PG full text search invocation' do
      nlq = double(:natlang_query, :attr => 'content', :op => 'contains', :val  => 'canjs,jquerypp')
      nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
      expect(nlqt.verb).to eq(:basic_search)
    end

    it 'transforms the "tagged_with" operator to acts_as_taggable "tagged_with" method' do
      nlq = double(:natlang_query, :attr => 'content', :op => 'tagged_with', :val  => 'canjs,jquerypp')
      nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
      expect(nlqt.verb).to eq(:tagged_with)
    end
    
    it 'transforms the "is" operator to a :where (an AR compatible method)' do
      nlq = double(:natlang_query, :attr => 'title', :op => 'is', :val  => 'simple')
      nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
      expect(nlqt.verb).to eq(:where)
    end
  end

  describe '#subject' do
    it 'transforms the "content" meta attrbute to the :whole keyword (we\'ll use it to decide if searching over a subset of text fields)' do
      nlq = double(:natlang_query, :attr => 'content', :op => 'is', :val  => 'canjs')
      nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
      expect(nlqt.subject).to eq(:whole)
    end

    it 'lets the attr be itself when it exists in the provided AR klass' do
      nlq = double(:natlang_query, :attr => 'title', :op => 'is', :val  => 'canjs')
      nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
      expect(nlqt.subject).to eq(:title)
    end
  end

  describe '#object' do
    it 'transforms the value to an array if the verb is about tagging (because acts_as_taggable expects arrays)' do
      nlq = double(:natlang_query, :attr => 'title', :op => 'contains', :val  => 'canjs,jquerypp')
      nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
      expect(nlqt.object).to eq('canjs,jquerypp')
    end

    it 'keeps the value as string if the verb is about text search (because textacular expects strings)' do
      nlq = double(:natlang_query, :attr => 'title', :op => 'tagged_with', :val  => 'canjs,jquerypp')
      nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
      expect(nlqt.object).to eq(%w(canjs jquerypp))
    end
    
    it 'transforms the "is" verb to a plain AR array query' do
      nlq = double(:natlang_query, :attr => 'title', :op => 'is', :val  => 'canjs')
      nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
      expect(nlqt.to_ar_query).to eq({:method => :where, :arg => ["title = ?", 'canjs']})
    end
  end

end
