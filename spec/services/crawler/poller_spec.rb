require 'spec_helper'
require 'services/crawler/poller'

require 'digest/md5'

describe Poller do
  describe "#reject_old" do
    let(:logger) { double(:logger, :info => nil) }
    let(:exchange) { double(:exchange, :publish => nil) }
    let(:poller) { Poller.new(logger, exchange,  'https://api.github.com/entities') {|c| c[:backlog_size] = 10}}

    it "should have a backlog of 10 items at most" do
      items = (1..13).map {|i| {title: i.to_s, id: i, hash_key: Digest::MD5.hexdigest(i.to_s)} }
      poller.reject_old(items)
      expect(poller.latest.length).to eql 10
    end

    it "should reject items with the same hash key" do
      items = (1..5).map {|i| {title: i.to_s, hash_key: Digest::MD5.hexdigest(i.to_s)} }
      new_items = (1..5).map {|i| {title: i.to_s, hash_key: Digest::MD5.hexdigest(i.to_s)} }
      poller.reject_old(new_items)
      poller.latest =~ items
    end

    it "should append items when there are no overlaps" do
      items = (1..4).map {|i| {title: i.to_s, hash_key: Digest::MD5.hexdigest(i.to_s)} }
      new_items = (5..8).map {|i| {title: i.to_s, hash_key: Digest::MD5.hexdigest(i.to_s)} }
      poller.reject_old(new_items)
      poller.latest =~ (items + new_items)
    end

    it "should push out old items when new ones come in and the array is full" do
      items = (1..7).map {|i| {title: i.to_s, hash_key: Digest::MD5.hexdigest(i.to_s)} }
      new_items = (8..11).map {|i| {title: i.to_s, hash_key: Digest::MD5.hexdigest(i.to_s)} }
      poller.reject_old(new_items)
      poller.latest =~ (4..11).map {|i| {title: i.to_s, hash_key: Digest::MD5.hexdigest(i.to_s)} }
    end
  end

end
