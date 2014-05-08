require 'no_rails_spec_helper'
require 'services/crawler/digest_set'

describe DigestSet do
  before(:all) { Redis.new(:url => ENV['REDIS_URL']).flushall }
  after(:all) { Redis.new(:url => ENV['REDIS_URL']).flushall }

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
  end
  
  describe "#key" do
    it "determines the key-path for a dispatched event" do
      set = DigestSet.new
      expect(set.key(events.first)).to eq "digests:nikica:github:commit"
    end
  end
end
