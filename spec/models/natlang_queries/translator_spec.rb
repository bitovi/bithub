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
      nlq = double(:natlang_query, attr_name: 'content', op: 'contains', val: 'canjs,jquerypp', negated?: false)
      nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
      expect(nlqt.verb).to eq(:advanced_search)
    end

    it 'transforms the "is" operator to a :where (an AR compatible method)' do
      nlq = double(:natlang_query, attr_name: 'title', op: 'is', val: 'simple', negated?: false)
      nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
      expect(nlqt.verb).to eq(:where)
    end
  end

  describe '#subject' do
    it 'transforms the "content" meta attrbute to the :whole keyword (we\'ll use it to decide if searching over a subset of text fields)' do
      nlq = double(:natlang_query, attr_name: 'content', op: 'is', val: 'canjs', negated?: false)
      nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
      expect(nlqt.subject).to eq(:whole)
    end

    it 'lets the attr be itself when it exists in the provided AR klass' do
      nlq = double(:natlang_query, attr_name: 'title', op: 'is', val: 'canjs', negated?: false)
      nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
      expect(nlqt.subject).to eq(:title)
    end
  end

  describe '#object' do
    it 'transforms the csv to "&" separated string which represents a conjunctive query' do
      nlq = double(:natlang_query, attr_name: 'title', op: 'contains_all', val: 'canjs,jquerypp', negated?: false)
      nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
      expect(nlqt.object).to eq({ 'title' => 'canjs&jquerypp' })
    end
    
    it 'transforms the csv to "|" separated string which represents a disjunctive query' do
      nlq = double(:natlang_query, attr_name: 'title', op: 'contains_any', val: 'canjs,jquerypp', negated?: false)
      nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
      expect(nlqt.object).to eq({ 'title' => 'canjs|jquerypp' })
    end

    it 'transforms the "is" verb to a plain AR array query' do
      nlq = double(:natlang_query, attr_name: 'title', op: 'is', val: 'canjs', negated?: false)
      nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
      expect(nlqt.to_ar_query).to eq({:method => :where, :arg => ["title = ?", 'canjs']})
    end
  end
end
