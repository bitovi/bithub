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

  describe '#moderate' do
    before do
      @embed = FactoryGirl.create(:embed, :restrictive)
      @embed.make_link_to(@e1 = FactoryGirl.create(:github_push))
      @embed.make_link_to(@e2 = FactoryGirl.create(:github_issue, title: 'eventmachine and haskell'))
      @embed.make_link_to(@e3 = FactoryGirl.create(:twitter_tweet, title: 'eventmachine is bad'))
      @embed.make_link_to(@e4 = FactoryGirl.create(:twitter_follow, title: 'Smile!! 😃 I\'ve found that if I do my plank pretty soon after waking up it is slightly easier 😜. 3 minutes up, 2 mins on my forearms no breaks. Finished up with superman & downward facing dog to loosen up my back.'))
      @embed.make_link_to(@e5 = FactoryGirl.create(:github_pull_request, url: 'http://this-is-also.searchable.com'))
      @embed.make_link_to(@e6 = FactoryGirl.create(:meetup_entity, :event, title: "a haskell meetup"))
    end

    context 'given a filter that translates to a "where" query' do
      it 'performs a where query and approves all items it detects' do
        @approving = FactoryGirl.create(:filter, action: 'approve', embed: @embed)
        FactoryGirl.create(:natlang_query, :is_from_twitter, filter: @approving)

        @embed.moderate
        expect(@embed.approved_entities).to match_array [@e3, @e4]
      end

      it 'filters by a given phrase' do
        @approving = FactoryGirl.create(:filter, action: 'approve', embed: @embed)
        f = FactoryGirl.create(:natlang_query, attr_name: 'title', op: 'contains_phrase', val: 'pretty soon after', filter: @approving)

        @embed.moderate
        expect(@embed.approved_entities).to match_array [@e4]
      end

      it 'filters by negated regular attribute (feed_name, type_name, etc.)' do
        @approving = FactoryGirl.create(:filter, action: 'approve', embed: @embed)
        FactoryGirl.create(:natlang_query, :is_from_twitter, :negated, filter: @approving)

        @embed.moderate
        expect(@embed.approved_entities).to match_array [@e1, @e2, @e5, @e6]
      end
    end
      
    context 'given a filter that translates to a full-text search query' do
      it 'performs a full text search on all attributes by conjunctively combining multiple terms and approves all items it detects' do
        @approving = FactoryGirl.create(:filter, action: 'approve', embed: @embed)
        FactoryGirl.create(:natlang_query, attr_name: 'title', op: 'contains_all', val: 'haskell,eventmachine', filter: @approving)

        @embed.moderate
        expect(@embed.approved_entities).to match_array [@e2]
      end

      it 'performs a full text search on all attributes by disjunctively combining multiple terms and approves all items it detects' do
        @approving = FactoryGirl.create(:filter, action: 'approve', embed: @embed)
        FactoryGirl.create(:natlang_query, attr_name: 'title', op: 'contains_any', val: 'haskell,eventmachine', filter: @approving)

        @embed.moderate
        expect(@embed.approved_entities).to match_array [@e2, @e3, @e6]
      end
    end

    context 'given a filter with multiple queries' do
      it 'filters by tying :contains and :is_a predicates with a logical AND' do
        @approving = FactoryGirl.create(:filter, action: 'approve', embed: @embed)
        FactoryGirl.create(:natlang_query, :contains_haskell, filter: @approving)
        FactoryGirl.create(:natlang_query, :is_from_twitter, :negated, filter: @approving)

        @embed.moderate
        expect(@embed.approved_entities).to match_array [@e2, @e6]
      end
    end
  end
end
