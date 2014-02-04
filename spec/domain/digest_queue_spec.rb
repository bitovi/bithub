require 'digest/md5'
require 'domain/spec_helper'
require 'app/domain/digest_queue'

describe DigestQueue do
  subject(:digest_queue) { DigestQueue.new }

  describe "#reject_old" do

    it "should have a backlog of 10 items at most" do
      items = (1..13).map {|i| make_dummy_event(i)}
      digest_queue.reject_old(items)
      expect(digest_queue.total_digests).to eql 10
    end

    it "should reject items already present events (with the same content_digest)" do
      items = (1..5).map {|i| make_dummy_event(i) }
      digest_queue = DigestQueue.new(items)

      new_items = (1..5).map {|i| make_dummy_event(i) }
      expect(digest_queue.reject_old(new_items)).to eql []
    end

    it "should append items when there are no overlaps" do
      items = (1..4).map {|i| make_dummy_event(i) }
      new_items = (5..8).map {|i| make_dummy_event(i) }

      digest_queue.reject_old(new_items)
      digest_queue.latest =~ (items + new_items)
    end

    it "should push out old items when new ones come in and the array is full" do
      items = (1..7).map {|i| make_dummy_event(i) }
      new_items = (8..11).map {|i| make_dummy_event(i) }

      digest_queue.reject_old(new_items)
      digest_queue.latest =~ (4..11).map {|i| make_dummy_event(i) }
    end
  end
end
