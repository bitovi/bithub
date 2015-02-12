require 'rails_helper'
require 'models/embed'

RSpec.describe Embed, :type => :model do

  describe '#approving_filter' do
    it 'finds the associated approving filter among all filters' do
      e = FactoryGirl.create(:embed, name: 'test embed')
      f = FactoryGirl.create(:filter, is_conj: true, classification: 'approving', embed: e)
      expect(e.approving_filter).to eq f
    end
  end
  
  describe '#blocking_filter' do
    it 'finds the associated blocking filter among all filters' do
      e = FactoryGirl.create(:embed, name: 'test embed')
      f = FactoryGirl.create(:filter, is_conj: true, classification: 'blocking', embed: e)
      expect(e.blocking_filter).to eq f
    end
  end

  describe '#approve_valid' do

    before do
      @embed = FactoryGirl.create(:embed)
      @embed.make_link_to(FactoryGirl.create(:github_pull_request), false)
      @embed.make_link_to(FactoryGirl.create(:github_push), false)
      @embed.make_link_to(FactoryGirl.create(:github_watch), false)
      @embed.make_link_to(FactoryGirl.create(:twitter_tweet), false)
      @embed.make_link_to(FactoryGirl.create(:twitter_follow), false)
      @embed.make_link_to(FactoryGirl.create(:meetup_entity, :event), false)
      @embed.reload
    end

    context 'given a filter with a single query' do
      before(:each) do
        @filter = FactoryGirl.create(:filter,
          is_conj: true,
          classification: 'approving',
          embed: @embed
        )
      end

      # it 'filters by a doing full text search' do
      #   @filter.natlang_queries << FactoryGirl.create(:natlang_query, :contains_haskell)

      #   @embed.approve_valid
      #   expect(@embed.approved_entities.length).to eq 1
      # end

      it 'filters by a regular attribute (feed_name, type_name, etc.)' do
        @filter.natlang_queries << FactoryGirl.create(:natlang_query, :is_from_twitter)

        @embed.approve_valid
        expect(@embed.reload.approved_entities.length).to eq 2
      end

      it 'filters by negated regular attribute (feed_name, type_name, etc.)' do
        @filter.natlang_queries << FactoryGirl.create(:natlang_query, :is_from_twitter, :negated)

        @embed.approve_valid
        expect(@embed.reload.approved_entities.length).to eq 4
      end

      it 'filters by present tags' do
        @filter.natlang_queries << FactoryGirl.create(:natlang_query, :tagged_with_canjs)

        @embed.approve_valid
        expect(@embed.reload.approved_entities.length).to eq 5
      end

      it 'filters by excluded tags' do
        @filter.natlang_queries << FactoryGirl.create(:natlang_query, :tagged_with_canjs, :negated)

        @embed.approve_valid
        expect(@embed.reload.approved_entities.length).to eq 1
      end
    end

    context 'given a filter with multiple conjunctive predicates' do
      it 'filters by tying :tagged_with and :is_a predicates with a logical AND' do
        @filter = FactoryGirl.create(:filter, :conjunctive, embed: @embed)

        @filter.natlang_queries << FactoryGirl.create(:natlang_query, :tagged_with_canjs)
        @filter.natlang_queries << FactoryGirl.create(:natlang_query, :is_from_twitter)

        @embed.approve_valid
        expect(@embed.reload.approved_entities.length).to eq 2
      end

      # it 'filters by tying :tagged_with and :contains predicates with a logical AND' do
      #   @filter = FactoryGirl.create(:filter, :conjunctive, embed: @embed)

      #   @filter.natlang_queries << FactoryGirl.create(:natlang_query, :tagged_with_canjs)
      #   @filter.natlang_queries << FactoryGirl.create(:natlang_query, :contains_haskell)

      #   @embed.approve_valid
      #   expect(@embed.approved_entities.length).to eq 0
      # end

      # it 'filters by tying :contains and :is_a predicates with a logical AND' do
      #   embed = FactoryGirl.create(:embed, name: "Embed for AND test", approved_by_default: true)
      #   filter = FactoryGirl.create(:filter, :conjunctive, embed: embed)
      #   filter.natlang_queries << FactoryGirl.create(:natlang_query, :contains_haskell)
      #   filter.natlang_queries << FactoryGirl.create(:natlang_query, :is_from_twitter, :negated)

      #   embed.approve_valid
      #   expect(embed.approved_entities.length).to eq 1
      # end
    end
    
    context 'given a filter with multiple disjunctive predicates' do
      after { Filter.delete_all; NatlangQuery.delete_all }

      it 'filters by tying all predicates with a logical OR' do
        embed = FactoryGirl.create(:embed, name: "Embed for disjunctive test")
        embed.make_link_to(FactoryGirl.create(:github_pull_request), false)
        embed.make_link_to(FactoryGirl.create(:github_push), false)
        embed.make_link_to(FactoryGirl.create(:github_watch), false)
        embed.make_link_to(FactoryGirl.create(:twitter_tweet), false)
        embed.make_link_to(FactoryGirl.create(:twitter_follow), false)

        filter = FactoryGirl.create(:filter, :disjunctive, embed: embed)
        filter.natlang_queries << FactoryGirl.create(:natlang_query, :tagged_with_canjs)
        filter.natlang_queries << FactoryGirl.create(:natlang_query, :is_from_twitter)

        embed.approve_valid
        expect(embed.reload.approved_entities.length).to eq 5
      end
    end
  end
end
