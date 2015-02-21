require 'supervisors/support/owner_data'

class SubscriptionRegistry
  include Celluloid

  SubscriptionKey = Struct.new :feed, :type, :id

  attr_reader :subscriptions

  def initialize(opts={})
    @subscriptions = Hash.new {|h,k| h[k]=[]}
  end

  def subscribe(feed, type, id, owner_data)
    key = SubscriptionKey.new feed, type, id
    @subscriptions[key].push owner_data
  end

  def unsubscribe(feed, type, id, owner_data)
    key = SubscriptionKey.new feed, type, id
    @subscriptions[key].delete owner_data
  end

  def [](feed, type, id)
    key = SubscriptionKey.new feed, type, id
    @subscriptions[key]
  end
end
