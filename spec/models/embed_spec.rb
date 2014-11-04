require 'rails_helper'
require 'models/embed'

RSpec.describe Embed, :type => :model do

  describe '#moderating_filter' do
    it 'finds the associated moderating filter among all filters' do
      e = Embed.create(:name => 'test embed')
      f = (e.filters.create(is_conj: true, classification: 'moderating'))
      expect(e.moderating_filter).to eq f
    end
  end
  
  describe '#blocking_filter' do
    it 'finds the associated blocking filter among all filters' do
      e = Embed.create(:name => 'test embed')
      f = (e.filters.create(:is_conj => true, :classification => 'blocking'))
      expect(e.blocking_filter).to eq f
    end
  end

  describe '#moderate' do
    before(:each) do
      @embed = FactoryGirl.create(:embed)

      @embed.make_link_to(FactoryGirl.create(:github_pull_request))
      @embed.make_link_to(FactoryGirl.create(:github_push))
      @embed.make_link_to(FactoryGirl.create(:github_watch))
      @embed.make_link_to(FactoryGirl.create(:twitter_tweet))
      @embed.make_link_to(FactoryGirl.create(:twitter_follow))
      @embed.make_link_to(FactoryGirl.create(:meetup_entity, :event))
    end

    context 'given a filter with a single query' do
      before(:each) do
        @filter = FactoryGirl.create(:filter,
          is_conj: true,
          classification: 'moderating',
          filterable: @embed
        )
      end

      it 'filters by a doing full text search' do
        @filter.natlang_queries << FactoryGirl.create(:natlang_query, :contains_haskell)

        @embed.moderate
        expect(@embed.approved_entities.length).to eq 1
      end

      it 'filters by a regular attribute (feed_name, type_name, etc.)' do
        @filter.natlang_queries << FactoryGirl.create(:natlang_query, :is_from_twitter)

        @embed.moderate
        expect(@embed.approved_entities.length).to eq 2
      end

      it 'filters by negated regular attribute (feed_name, type_name, etc.)' do
        @filter.natlang_queries << FactoryGirl.create(:natlang_query, :is_from_twitter, :negated)

        @embed.moderate
        expect(@embed.approved_entities.length).to eq 4
      end

      it 'filters by present tags' do
        @filter.natlang_queries << FactoryGirl.create(:natlang_query, :tagged_with_canjs)

        @embed.moderate
        expect(@embed.approved_entities.length).to eq 5
      end

      it 'filters by excluded tags' do
        @filter.natlang_queries << FactoryGirl.create(:natlang_query, :tagged_with_canjs, :negated)

        @embed.moderate
        expect(@embed.approved_entities.length).to eq 1
      end
    end

    context 'given a filter with multiple conjunctive predicates' do
      it 'filters by tying :tagged_with and :is_a predicates with a logical AND' do
        @filter = FactoryGirl.create(:filter, :conjunctive, filterable: @embed)

        @filter.natlang_queries << FactoryGirl.create(:natlang_query, :tagged_with_canjs)
        @filter.natlang_queries << FactoryGirl.create(:natlang_query, :is_from_twitter)

        @embed.moderate
        expect(@embed.approved_entities.length).to eq 2
      end

      it 'filters by tying :tagged_with and :contains predicates with a logical AND' do
        @filter = FactoryGirl.create(:filter, :conjunctive, filterable: @embed)

        @filter.natlang_queries << FactoryGirl.create(:natlang_query, :tagged_with_canjs)
        @filter.natlang_queries << FactoryGirl.create(:natlang_query, :contains_haskell)

        @embed.moderate
        expect(@embed.approved_entities.length).to eq 0
      end

      it 'filters by tying :contains and :is_a predicates with a logical AND' do
        @filter = FactoryGirl.create(:filter, :conjunctive, filterable: @embed)

        @filter.natlang_queries << FactoryGirl.create(:natlang_query, :contains_haskell)
        @filter.natlang_queries << FactoryGirl.create(:natlang_query, :is_from_twitter, :negated)

        @embed.moderate
        expect(@embed.approved_entities.length).to eq 1
      end
    end
    
    context 'given a filter with multiple disjunctive predicates' do
      it 'filters by tying all predicates with a logical OR' do
        @filter = FactoryGirl.create(:filter, :disjunctive, filterable: @embed)

        @filter.natlang_queries << FactoryGirl.create(:natlang_query, :tagged_with_canjs)
        @filter.natlang_queries << FactoryGirl.create(:natlang_query, :is_from_twitter)

        @embed.moderate
        expect(@embed.approved_entities.length).to eq 5
      end
    end
  end
end
