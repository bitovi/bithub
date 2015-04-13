require 'rails_helper'
require 'models/embed'

RSpec.describe Embed, :type => :model do

  describe '#determine_state' do
    context 'the embed is strict (approved_by_default is false)' do
      it 'determines state for entities coming in' do
        embed  = FactoryGirl.create(:embed, approved_by_default: false)
        filter = FactoryGirl.create(:filter, action: 'approve', embed: embed)
        nlq    = FactoryGirl.create(:natlang_query, :is_from_twitter, filter: filter)
        e1     = FactoryGirl.create(:twitter_entity, :tweet)
        e2     = FactoryGirl.create(:meetup_entity, :event)
        expect(embed.determine_state e1).to be_truthy
        expect(embed.determine_state e2).to be_falsey
      end
    end

    context 'the embed is lax (approved_by_default is true)' do
      it 'determines state for entities coming in' do
        embed  = FactoryGirl.create(:embed, approved_by_default: true)
        filter = FactoryGirl.create(:filter, action: 'block', embed: embed)
        nql    = FactoryGirl.create(:natlang_query, :contains_haskell, filter: filter)
        e1     = FactoryGirl.create(:github_issue, title: 'haskell is awesome')
        e2     = FactoryGirl.create(:github_issue, title: 'canjs is awesome')
        expect(embed.determine_state e1).to be_falsey
        expect(embed.determine_state e2).to be_truthy
      end
    end
  end

  describe '#approve_valid' do
    before do
      @embed = FactoryGirl.create(:embed, :restrictive)
      @embed.make_link_to(FactoryGirl.create :github_push)
      @embed.make_link_to(FactoryGirl.create :github_issue, title: 'eventmachine and haskell')
      @embed.make_link_to(FactoryGirl.create :twitter_tweet, title: 'eventmachine is bad')
      @embed.make_link_to(FactoryGirl.create :twitter_follow)
      @embed.make_link_to(FactoryGirl.create :github_pull_request)
      @embed.make_link_to(FactoryGirl.create(:meetup_entity, :event, title: "a haskell meetup"))
    end

    context 'given a filter with a single query' do
      before(:each) do
        @filter = FactoryGirl.create(:filter, action: 'approve', embed: @embed)
      end

      it 'filters by a regular attribute (feed_name, type_name, etc.)' do
        FactoryGirl.create(:natlang_query, :is_from_twitter, filter: @filter)

        @embed.approve_valid
        expect(@embed.approved_entities.length).to eq 2
      end

      it 'filters by negated regular attribute (feed_name, type_name, etc.)' do
        FactoryGirl.create(:natlang_query, :is_from_twitter, :negated, filter: @filter)

        @embed.approve_valid
        expect(@embed.approved_entities.count).to eq 4
      end
      
      it 'performs a full text search by one attribute' do
        FactoryGirl.create(:natlang_query, attr: 'title', op: 'contains', val: 'haskell,eventmachine', filter: @filter)

        @embed.approve_valid
        expect(@embed.approved_entities.length).to eq 1
      end
      
      it 'performs a full text search on all attributes by conjunctively combining multiple terms' do
        FactoryGirl.create(:natlang_query, attr: 'content', op: 'contains_all', val: 'haskell,eventmachine', filter: @filter)

        @embed.approve_valid
        expect(@embed.approved_entities.length).to eq 1
      end
      
      it 'performs a full text search on all attributes by disjunctively combining multiple terms' do
        FactoryGirl.create(:natlang_query, attr: 'content', op: 'contains_any', val: 'haskell,eventmachine', filter: @filter)

        @embed.approve_valid
        expect(@embed.approved_entities.length).to eq 3
      end
      
      it 'performs a full text search with negation' do
        FactoryGirl.create(:natlang_query, attr: 'title', op: 'contains_all', val: '!haskell', filter: @filter)

        @embed.approve_valid
        expect(@embed.approved_entities.length).to eq 4
      end
    end

    # context 'given a filter with multiple queries' do
    #   after { Filter.delete_all; NatlangQuery.delete_all }

    #   it 'filters by tying :contains and :is_a predicates with a logical AND' do
    #     embed = FactoryGirl.create(:embed, name: "Embed for AND test", approved_by_default: true)
    #     filter = FactoryGirl.create(:filter, embed: embed)
    #     filter.natlang_queries << FactoryGirl.create(:natlang_query, :contains_haskell)
    #     filter.natlang_queries << FactoryGirl.create(:natlang_query, :is_from_twitter, :negated)

    #     embed.approve_valid
    #     expect(embed.approved_entities.length).to eq 1
    #   end
    # end
  end
end
