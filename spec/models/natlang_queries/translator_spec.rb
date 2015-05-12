require 'spec_helper'
require 'models/natlang_queries/translator'

class PGColumn
  def initialize(type)
    @type = type
  end
  attr_reader :type
end

class DummyARClass
  def self.has_an_attribute?(whatever)
    true
  end

  def self.columns_hash
    Hash[
      'title', PGColumn.new(:string),
      'author', PGColumn.new(:string),
      'feed_name', PGColumn.new(:string),
      'type_name', PGColumn.new(:string)
    ]
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

      it 'translates the "starts_with", "ends_with" and "like" op to a AR.where' do
        nlq1 = double(:natlang_query, attr_name: 'title', op: 'like', val: 'simple', negated?: false)
        nlq2 = double(:natlang_query, attr_name: 'title', op: 'starts_with', val: 'simple', negated?: false)
        nlq3 = double(:natlang_query, attr_name: 'title', op: 'ends_with', val: 'simple', negated?: false)
        nlqt1 = NatlangQueries::Translator.new(nlq1, DummyARClass)
        nlqt2 = NatlangQueries::Translator.new(nlq2, DummyARClass)
        nlqt3 = NatlangQueries::Translator.new(nlq3, DummyARClass)
        expect(nlqt1.tmethod).to eq(:where)
        expect(nlqt2.tmethod).to eq(:where)
        expect(nlqt3.tmethod).to eq(:where)
      end
    end
  end

  describe '#targuments' do
    it 'translates the "contains" op to AR.advanced_search compatible argument' do
      nlq = double(:natlang_query, attr_name: 'title', op: 'contains_all', val: 'canjs,jquerypp', negated?: false)
      nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
      expect(nlqt.targuments).to eq({'searchable_title' => 'canjs&jquerypp'})
    end

    it 'translates the "is" op to a AR.where compatible argument' do
      nlq = double(:natlang_query, attr_name: 'title', op: 'is', val: 'canjs', negated?: false)
      nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
      expect(nlqt.targuments).to eq(["title = ?", 'canjs'])
    end
    
    it 'translates the "starts_with", "ends_with" and "like" op to a AR.where compatible argument' do
      nlq = double(:natlang_query, attr_name: 'author', op: 'starts_with', val: 'nik', negated?: false)
      nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
      expect(nlqt.targuments).to eq(["author ILIKE ?", 'nik%'])
    end

  end

  describe '#where_column' do
    it 'translates the attr_name to itself when it exists in the provided AR klass' do
      nlq = double(:natlang_query, attr_name: 'title', op: 'is', val: 'canjs', negated?: false)
      nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
      expect(nlqt.where_column).to eq('title')
    end

    context 'when attr_name is equal to \'content\'' do
      it 'translates it to the \'body\' column' do
        nlq = double(:natlang_query, attr_name: 'content', op: 'contains_phrase', val: 'canjs', negated?: false)
        nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
        expect(nlqt.where_column).to eq('body')
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

    context 'given the op is regex based"' do
      context ' and the query is affirmative' do
        it 'translates the op to "ILIKE"' do
          nlq = double(:natlang_query, attr_name: 'title', op: 'like', val: 'canjs', negated?: false)
          nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
          expect(nlqt.where_op).to eq('ILIKE')
        end
      end

      context ' and the query is negative' do
        it 'translates the op to "NOT ILIKE"' do
          nlq = double(:natlang_query, attr_name: 'title', op: 'like', val: 'canjs', negated?: true)
          nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
          expect(nlqt.where_op).to eq('NOT ILIKE')
        end
      end
    end
  end

  describe '#where_value' do
    context 'when op is "like"' do
      it 'wraps the value in "%"' do
        nlq = double(:natlang_query, attr_name: 'author', op: 'like', val: 'canjs', negated?: false)
        nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
        expect(nlqt.where_value).to eq('%canjs%')
      end
    end
    context 'when op is "starts_with"' do
      it 'appends "%" to value' do
        nlq = double(:natlang_query, attr_name: 'author', op: 'starts_with', val: 'canjs', negated?: false)
        nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
        expect(nlqt.where_value).to eq('canjs%')
      end
    end
    context 'when op is "ends_with"' do
      it 'prepends "%" to value' do
        nlq = double(:natlang_query, attr_name: 'author', op: 'ends_with', val: 'canjs', negated?: false)
        nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
        expect(nlqt.where_value).to eq('%canjs')
      end
    end

    context 'when op is "contains_phrase"' do
      it 'wraps the value in "%"' do
        nlq = double(:natlang_query, attr_name: 'author', op: 'contains_phrase', val: 'canjs', negated?: false)
        nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
        expect(nlqt.where_value).to eq('%canjs%')
      end
    end
  end

  describe '#search_attr' do
    context 'given the search_attr is searchable' do
      it 'translates the attr_name to it\s searchable couterpart' do
        nlq = double(:natlang_query, attr_name: 'title', op: 'contains_any', val: 'canjs,jquerypp', negated?: false)
        nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
        expect(nlqt.search_attr).to eq('searchable_title')
      end
    end

    context 'givent the search_attr is un-searchable' do
      it 'doesn\t translate the attr_name (returns nil)' do
        nlq = double(:natlang_query, attr_name: 'feed_name', op: 'contains_any', val: 'canjs,jquerypp', negated?: false)
        nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
        expect(nlqt.search_attr).to be_nil
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

  describe '#op_translated_to_full_text_search?' do
    context 'when op is along the lines of contains*' do
      it 'confirms that the query should be translated to something Textacular can deal with' do
        nlq = double(:natlang_query, attr_name: 'title', op: 'contains_all', val: 'canjs,jquerypp', negated?: false)
        nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
        expect(nlqt.op_translated_to_full_text_search?).to be_truthy
      end
    end
  end
  
  describe '#op_translated_to_like?' do
    context 'when op is about phrasing or starts/ends with' do
      it 'confirms that the query should be translated to something SQL ILIKE predicate can deal with' do
        nlq = double(:natlang_query, attr_name: 'title', op: 'contains_phrase', val: 'canjs is better than jquerypp', negated?: false)
        nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
        expect(nlqt.op_translated_to_like?).to be_truthy
      end
    end
  end
  
  describe '#op_translated_to_like?' do
    context 'when attr_name is equal to \'content\'' do
      it 'considers that attr_name defined and treats it as a string column' do
        nlq = double(:natlang_query, attr_name: 'content', op: 'contains_phrase', val: 'canjs is better than jquerypp', negated?: false)
        nlqt = NatlangQueries::Translator.new(nlq, DummyARClass)
        expect(nlqt.attribute_defined?).to be_truthy
        expect(nlqt.attribute_is_string?).to be_truthy
      end
    end
  end
end
