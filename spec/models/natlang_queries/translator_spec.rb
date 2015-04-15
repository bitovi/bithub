require 'spec_helper'
require 'models/natlang_queries/translator'

class DummyARClass
  def self.has_an_attribute?(whatever)
    true
  end
end

RSpec.describe NatlangQueries::Translator, :type => :model do

  describe '#tmethod' do
    context 'generally' do
      it 'translates the "contains" op to AR.advanced_search' do
        nlq = double(:natlang_query, attr_name: 'content', op: 'contains', val: 'canjs,jquerypp', negated?: false)
        nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
        expect(nlqt.tmethod).to eq(:advanced_search)
      end

      it 'translates the "is" op to a AR.where' do
        nlq = double(:natlang_query, attr_name: 'title', op: 'is', val: 'simple', negated?: false)
        nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
        expect(nlqt.tmethod).to eq(:where)
      end
    end

    context 'given an "author" as attr_name' do
      it 'translates the "contains" op to AR.where' do
        nlq = double(:natlang_query, attr_name: 'author', op: 'contains', val: 'canjs', negated?: false)
        nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
        expect(nlqt.tmethod).to eq(:where)
      end
    end
  end

  describe '#targuments' do
    it 'translates the "contains_all" op to AR.advanced_search compatible argument' do
      nlq = double(:natlang_query, attr_name: 'title', op: 'contains_all', val: 'canjs,jquerypp', negated?: false)
      nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
      expect(nlqt.targuments).to eq({ 'title' => 'canjs&jquerypp' })
    end

    it 'translates the "contains_any" op to AR.advanced_search compatible argument' do
      nlq = double(:natlang_query, attr_name: 'title', op: 'contains_any', val: 'canjs,jquerypp', negated?: false)
      nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
      expect(nlqt.targuments).to eq({ 'title' => 'canjs|jquerypp' })
    end

    it 'translates the "is" op to a AR.where compatible argument' do
      nlq = double(:natlang_query, attr_name: 'title', op: 'is', val: 'canjs', negated?: false)
      nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
      expect(nlqt.targuments).to eq ["title = ?", 'canjs']
    end

    context 'given an "author" as a attr' do
      it 'translates the "is" op to a "where =" SQL query' do
        nlq = double(:natlang_query, attr_name: 'author', op: 'is', val: 'nikica', negated?: false)
        nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
        expect(nlqt.targuments).to eq ["props -> 'origin_author_name' = ?", 'nikica']
      end

      it 'translates the "contains*" op to a "where LIKE" SQL query' do
        nlq = double(:natlang_query, attr_name: 'author', op: 'contains', val: 'nikica', negated?: false)
        nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
        expect(nlqt.targuments).to eq(["props -> 'origin_author_name' LIKE ?", '%nikica%'])
      end

      context 'and the query is negative' do
        it 'translates the "is" op to a "where <>" SQL query' do
          nlq = double(:natlang_query, attr_name: 'author', op: 'is', val: 'nikica', negated?: true)
          nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
          expect(nlqt.targuments).to eq ["props -> 'origin_author_name' <> ?", 'nikica']
        end

        it 'translates the "contains*" op to a "where NOT LIKE" SQL query' do
          nlq = double(:natlang_query, attr_name: 'author', op: 'contains', val: 'nikica', negated?: true)
          nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
          expect(nlqt.targuments).to eq(["props -> 'origin_author_name' NOT LIKE ?", '%nikica%'])
        end
      end
    end
  end

  describe '#where_column' do
    it 'translates the attr_name to itself when it exists in the provided AR klass' do
      nlq = double(:natlang_query, attr_name: 'title', op: 'is', val: 'canjs', negated?: false)
      nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
      expect(nlqt.where_column).to eq('title')
    end

    context 'given an attribute that is stored in props (Hstore)' do
      it 'translates the attr to target the hstore property' do
        nlq = double(:natlang_query, attr_name: 'author', op: 'is', val: 'canjs', negated?: false)
        nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
        expect(nlqt.where_column).to eq("props -> 'origin_author_name'")
      end
    end
  end

  describe '#where_op' do
    context 'given the op is "is"' do
      context 'and the query is affirmative' do
        it 'translates the op to "="' do
          nlq = double(:natlang_query, attr_name: 'title', op: 'is', val: 'canjs', negated?: false)
          nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
          expect(nlqt.where_op).to eq('=')
        end
      end

      context 'and the query is negative' do
        it 'translates the op to "<>"' do
          nlq = double(:natlang_query, attr_name: 'title', op: 'is', val: 'canjs', negated?: true)
          nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
          expect(nlqt.where_op).to eq('<>')
        end
      end
    end

    context 'given the op is "contains*"' do
      context ' and the query is affirmative' do
        it 'translates the op to "LIKE" ' do
          nlq = double(:natlang_query, attr_name: 'title', op: 'contains', val: 'canjs', negated?: false)
          nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
          expect(nlqt.where_op).to eq('LIKE')
        end
      end

      context ' and the query is negative' do
        it 'translates the op to "NOT LIKE"' do
          nlq = double(:natlang_query, attr_name: 'title', op: 'contains', val: 'canjs', negated?: true)
          nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
          expect(nlqt.where_op).to eq('NOT LIKE')
        end
      end
    end
  end

  describe '#where_value' do
    context 'when the attr is "author" and op is "contains"' do
      it 'wraps the value in "%"' do
        nlq = double(:natlang_query, attr_name: 'author', op: 'contains', val: 'canjs', negated?: false)
        nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
        expect(nlqt.where_value).to eq('%canjs%')
      end
    end
  end

  describe '#search_value' do
    context 'given a value with comma separated values' do
      context 'and the op is "contains_any"' do
        it 'translates the value to "|" separated values' do
          nlq = double(:natlang_query, attr_name: 'title', op: 'contains_any', val: 'canjs,jquerypp', negated?: false)
          nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
          expect(nlqt.search_value).to eq('canjs|jquerypp')
        end
      end

      context 'and the op is "contains_all"' do
        it 'translates the value to "&" separated values' do
          nlq = double(:natlang_query, attr_name: 'title', op: 'contains_all', val: 'canjs,jquerypp', negated?: false)
          nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
          expect(nlqt.search_value).to eq('canjs&jquerypp')
        end
      end
    end
  end
end
