require 'services/crawler/listener/subscription_registry'

describe SubscriptionRegistry do

  before :each do
    @registry = SubscriptionRegistry.new
  end

  describe '#[]' do
    it 'returns subscriptions by feed-type-id key' do
      @registry.subscribe 'feed', 'type', 1, :foo
      @registry.subscribe 'feed', 'type', 1, :bar
      @registry.subscribe 'feed', 'other_type', 1, :baz

      expect(@registry['feed','type',1]).to include :foo, :bar
      expect(@registry['feed','other_type',1]).to include :baz
      expect(@registry['non','existing',1]).to be_empty
    end
  end

  describe '#unsubscribe' do
    it 'removes owner_data from the feed-type-id array' do
      @registry.subscribe 'feed', 'type', 1, :foo # same key
      @registry.subscribe 'feed', 'type', 1, :bar # same key
      @registry.subscribe 'feed', 'other_type', 1, :baz

      @registry.unsubscribe('feed', 'type', 1, :bar)
      expect(@registry['feed','type',1]).to include :foo

      @registry.unsubscribe('feed', 'type', 1, :foo)
      expect(@registry['feed','type',1]).to be_empty

      @registry.unsubscribe('feed', 'other_type', 1, :baz)
      expect(@registry['feed','other_type',1]).to be_empty

    end
  end
end
