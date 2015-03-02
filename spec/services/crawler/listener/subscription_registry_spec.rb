require 'services/crawler/listener/subscription_registry'

describe SubscriptionRegistry do

  before { Celluloid.boot }
  after { Celluloid.shutdown }

  before :each do
    @registry = SubscriptionRegistry.new
  end

  describe '#subscribe' do
    it 'valid key values must be passed' do
      expect(@registry.subscribe 'feed', nil, 1, :foo).to be_nil
    end

    it 'doesnt push existing values' do
      @registry.subscribe 'feed', 'type', 1, {foo: {bar: 1}}
      @registry.subscribe 'feed', 'type', 1, {foo: {bar: 1}}

      expect(@registry['feed','type',1].count).to eq 1
    end
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
