# -*- coding: utf-8 -*-
require 'rails_helper'
require 'models/hub'

RSpec.describe Hub, :type => :model do

  describe '#determine_state' do
    context 'the hub is strict (approved_by_default is false)' do
      it 'determines state for bits coming in' do
        hub  = FactoryGirl.create(:hub, approved_by_default: false)
        filter = FactoryGirl.create(:filter, action: 'approve', hub: hub)
        nlq    = FactoryGirl.create(:natlang_query, :is_from_twitter, filter: filter)
        e1     = FactoryGirl.create(:twitter_bit, :tweet)
        e2     = FactoryGirl.create(:meetup_bit, :event)

        expect((hub.determine_state e1).decision).to eq("approved")
        expect((hub.determine_state e2).decision).to eq("pending")
      end
    end

    context 'the hub is lax (approved_by_default is true)' do
      it 'determines state for bits coming in' do
        hub  = FactoryGirl.create(:hub, approved_by_default: true)
        filter = FactoryGirl.create(:filter, action: 'block', hub: hub)
        nql    = FactoryGirl.create(:natlang_query, :contains_haskell, filter: filter)
        e1     = FactoryGirl.create(:github_issue, title: 'haskell is awesome')
        e2     = FactoryGirl.create(:github_issue, title: 'canjs is awesome')

        expect((hub.determine_state e1).decision).to eq("deleted")
        expect((hub.determine_state e2).decision).to eq("approved")
      end
    end

    context 'the hub is strict (approved_by_default is false) but the service is lax (approved_by_default is true)' do
      it 'takes the service\'s setting over the hub\'s setting' do
        hub   = FactoryGirl.create(:hub, name: 'foobar', approved_by_default: false)
        service = FactoryGirl.create(:github_service, approved_by_default: true, hub: hub)
        e1      = FactoryGirl.create(:github_issue, title: 'blocked bit')
        e2      = FactoryGirl.create(:github_issue, title: 'approved by service bit', services: [service])
        
        expect((service.hub.determine_state e1).decision).to eq("pending")
        expect((service.hub.determine_state e2).decision).to eq("approved")
      end
    end
  end

  describe '#moderate' do
    before do
      @hub = FactoryGirl.create(:hub, :restrictive)
      @hub.make_link_to(@e1 = FactoryGirl.create(:github_push))
      @hub.make_link_to(@e2 = FactoryGirl.create(:github_issue, title: 'eventmachine and haskell'))
      @hub.make_link_to(@e3 = FactoryGirl.create(:twitter_tweet, title: 'eventmachine is bad'))
      @hub.make_link_to(@e4 = FactoryGirl.create(:twitter_follow, title: 'Smile!! 😃 I\'ve found that if I do my plank pretty soon after waking up it is slightly easier 😜. 3 minutes up, 2 mins on my forearms no breaks. Finished up with superman & downward facing dog to loosen up my back.'))
      @hub.make_link_to(@e5 = FactoryGirl.create(:github_pull_request, url: 'http://this-is-also.searchable.com'))
      @hub.make_link_to(@e6 = FactoryGirl.create(:meetup_bit, :event, title: "a haskell meetup"))
    end

    context 'given a filter that translates to a "where" query' do
      it 'performs a where query and approves all items it detects' do
        @approving = FactoryGirl.create(:filter, action: 'approve', hub: @hub)
        FactoryGirl.create(:natlang_query, :is_from_twitter, filter: @approving)

        @hub.moderate
        expect(@hub.approved_bits).to match_array [@e3, @e4]
      end

      it 'filters by a given phrase' do
        @approving = FactoryGirl.create(:filter, action: 'approve', hub: @hub)
        f = FactoryGirl.create(:natlang_query, attr_name: 'title', op: 'contains_phrase', val: 'pretty soon after', filter: @approving)

        @hub.moderate
        expect(@hub.approved_bits).to match_array [@e4]
      end

      it 'filters by negated regular attribute (feed_name, type_name, etc.)' do
        @approving = FactoryGirl.create(:filter, action: 'approve', hub: @hub)
        FactoryGirl.create(:natlang_query, :is_from_twitter, :negated, filter: @approving)

        @hub.moderate
        expect(@hub.approved_bits).to match_array [@e1, @e2, @e5, @e6]
      end
    end

    context 'given a filter that translates to a full-text search query' do
      it 'performs a full text search on all attributes by conjunctively combining multiple terms and approves all items it detects' do
        @approving = FactoryGirl.create(:filter, action: 'approve', hub: @hub)
        FactoryGirl.create(:natlang_query, attr_name: 'title', op: 'contains_all', val: 'haskell,eventmachine', filter: @approving)

        @hub.moderate
        expect(@hub.approved_bits).to match_array [@e2]
      end

      it 'performs a full text search on all attributes by disjunctively combining multiple terms and approves all items it detects' do
        @approving = FactoryGirl.create(:filter, action: 'approve', hub: @hub)
        FactoryGirl.create(:natlang_query, attr_name: 'title', op: 'contains_any', val: 'haskell,eventmachine', filter: @approving)

        @hub.moderate
        expect(@hub.approved_bits).to match_array [@e2, @e3, @e6]
      end
    end

    context 'given a filter with multiple queries' do
      it 'filters by tying :contains and :is_a predicates with a logical AND' do
        @approving = FactoryGirl.create(:filter, action: 'approve', hub: @hub)
        FactoryGirl.create(:natlang_query, :contains_haskell, filter: @approving)
        FactoryGirl.create(:natlang_query, :is_from_twitter, :negated, filter: @approving)

        @hub.moderate
        expect(@hub.approved_bits).to match_array [@e2, @e6]
      end
    end
  end
end
