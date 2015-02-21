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

  describe '#handle_message' do
    it 'creates subscription from message' do
      msg = {
        brand: { id: 1, name: 'foo'},
        embed: { id: 2, name: 'bar'},
        service: { id: 3, feed_name: 'feed', type_name: 'type', config: { id: 4, some: 'config'}},
        signature: 'service_start',
        action: :start
      }

      owner_data = OwnerData.new 1, 'foo', 2, 'bar', 3, 'feed', 'type'

      @registry.handle_message msg
      expect(@registry['feed','type',4]).to include owner_data
    end
  end

end
