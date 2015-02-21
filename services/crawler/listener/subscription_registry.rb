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

  def handle_message(msg)
    action     = msg.fetch :action
    service    = msg.fetch :service
    owner_data = build_owner_data_from_message msg

    if action == :start
      subscribe service[:feed_name], service[:type_name], service[:config][:id], owner_data
    elsif action == :stop
      unsubscribe service[:feed_name], service[:type_name], service[:config][:id], owner_data
    else
      # handle restart :/
    end
  end

  private

  def build_owner_data_from_message(msg)
    b = msg.fetch :brand
    e = msg.fetch :embed
    s = msg.fetch :service

    OwnerData.new b[:id], b[:name], e[:id], e[:name], s[:id], s[:feed_name], s[:type_name]
  end

end
