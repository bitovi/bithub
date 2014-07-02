require 'no_rails_spec_helper'
require 'services/crawler/persistent/digest_set'

class DummySet < RedisSet
  def key(data_elem)
    colon_separated [data_elem.fetch(:name)]
  end

  def value(data_elem)
    data_elem.fetch(:data)
  end
end

describe DummySet do
  before { Redis.new(:url => ENV['REDIS_URL']).flushall }
  after { Redis.new(:url => ENV['REDIS_URL']).flushall }

  let(:data_set) do
    [{
      :name => "first",
      :data => %w(joffery died)
    }, {
      :name => "second",
      :data => %w(and so will the the viper)
    }]
  end

  describe "#add_many" do
    it "adds many stuff to redis, and checks if everything was added" do
      set = DummySet.new
      expect(set.add_many(data_set)).to be_truthy
    end

    it "responds with 'false' if trying to add an already present elem" do
      set = DummySet.new
      events_with_duplicate = ([] + data_set) << data_set.first
      expect(set.add_many(events_with_duplicate)).to be_falsey
    end
  end

  describe "#add" do
    it "responds with 'false' when trying to add an already present elem" do
      set = DummySet.new
      expect(set.add(data_set.first)).to be_truthy
      expect(set.add(data_set.first)).to be_falsey
    end
  end
  
  describe "#key" do
    it "determines the key-path for a dispatched event" do
      set = DummySet.new
      expect(set.key(data_set.first)).to eq "first"
    end
  end
  
  describe "#all" do
    it "returns all elements of an event" do
      set = DummySet.new
      expect(set.add_many(data_set)).to be_truthy
      expect(set.members("digests:nikica:github:commit")).to eq data_set\
        .select {|e| e[:content_digest] == "2384er9hufndjklsm"}\
        .map {|e| e[:content_digest]}
    end
  end
end
