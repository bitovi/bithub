require 'no_rails_spec_helper'
require 'services/crawler/persistent/digest_set'

describe DigestSet do
  before { Redis.new(:url => ENV['REDIS_URL']).flushall }
  after { Redis.new(:url => ENV['REDIS_URL']).flushall }

  let(:events) do
    [{
      :content_digest => "2384er9hufndjklsm",
      :meta => {
        :brand_name => "nikica",
        :feed_name => "github",
        :type_name => "commit"
      }
    }, {
      :content_digest => "4r9jfgndkmsojkdjsfln",
      :meta => {
        :brand_name => "veljko",
        :feed_name => "facebook",
        :type_name => "status"
      }
    }]
  end

  describe "#add_many" do
    it "adds many stuff to redis, and checks if everything was added" do
      set = DigestSet.new
      expect(set.add_many(events)).to eq true
    end

    it "responds with 'false' if trying to add an already present elem" do
      set = DigestSet.new
      events_with_duplicate = ([] + events) << events.first
      expect(set.add_many(events_with_duplicate)).to eq false
    end
  end

  describe "#add" do
    it "responds with 'false' when trying to add an already present elem" do
      set = DigestSet.new
      expect(set.add(events.first)).to eq true
      expect(set.add(events.first)).to eq false
    end
  end
  
  describe "#key" do
    it "determines the key-path for a dispatched event" do
      set = DigestSet.new
      expect(set.key(events.first)).to eq "digests:nikica:github:commit"
    end
  end
  
  describe "#all" do
    it "returns all elements of an event" do
      set = DigestSet.new
      expect(set.add_many(events)).to eq true
      expect(set.members("digests:nikica:github:commit")).to eq events\
        .select {|e| e[:content_digest] == "2384er9hufndjklsm"}\
        .map {|e| e[:content_digest]}
    end
  end
end
