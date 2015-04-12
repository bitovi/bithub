require 'rails_helper'
require 'models/embed'

RSpec.describe Embed, :type => :model do

  describe '#approving_filter' do
    it 'finds the associated approving filter among all filters' do
      e = FactoryGirl.create(:embed, name: 'test embed')
      f = FactoryGirl.create(:filter, action: 'approve', embed: e)
      expect(e.approving_filter).to eq f
    end
  end

  describe '#blocking_filter' do
    it 'finds the associated blocking filter among all filters' do
      e = FactoryGirl.create(:embed, name: 'test embed')
      f = FactoryGirl.create(:filter, action: 'block', embed: e)
      expect(e.blocking_filter).to eq f
    end
  end

  describe '#approve_valid' do

    before do
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
          action: 'approve',
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
        expect(@embed.approved_entities.length).to eq 2
      end

      it 'filters by negated regular attribute (feed_name, type_name, etc.)' do
        @filter.natlang_queries << FactoryGirl.create(:natlang_query, :is_from_twitter, :negated)

        @embed.approve_valid
        expect(@embed.approved_entities.count).to eq 4
      end
    end

    context 'given a filter with multiple conjunctive predicates' do
      after { Filter.delete_all; NatlangQuery.delete_all }

      # it 'filters by tying :contains and :is_a predicates with a logical AND' do
      #   embed = FactoryGirl.create(:embed, name: "Embed for AND test", approved_by_default: true)
      #   filter = FactoryGirl.create(:filter, embed: embed)
      #   filter.natlang_queries << FactoryGirl.create(:natlang_query, :contains_haskell)
      #   filter.natlang_queries << FactoryGirl.create(:natlang_query, :is_from_twitter, :negated)

      #   embed.approve_valid
      #   expect(embed.approved_entities.length).to eq 1
      # end
    end

  end
end
