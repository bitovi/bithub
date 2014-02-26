require 'domain/events/spec_helper'

describe Events::Forum::Post do
    
  let(:raw_rss_item) do
    raw_data(response_path: 'forum/posts.rss')['rss']['channel']['item'].first
  end
  
  subject(:item_wrapper) do
    Events::Forum::Post.new(raw_rss_item)
  end

  subject(:post_event) do
    Events::Forum::Post.new(raw_rss_item)
  end

  describe "#content_digest" do
    it "should calculate the digest using 'link' and class name" do
      seed = raw_rss_item['link'] + "Events::Forum::Post"
      expect(post_event.digest_seed).to eq seed
    end
  end

  describe "#url" do
    it "should delegate to #link" do
      expect(post_event.url).to eq item_wrapper.link
    end
  end
  
  describe "#subforum" do
    it "should delegate to #category" do
      expect(post_event.subforum).to eq item_wrapper.category
    end
  end

  describe "#origin_author_name" do
    it "should respond with 'dc:creator' from raw response" do
      expect(post_event.origin_author_name).to eq raw_rss_item['dc:creator']
    end
  end
  
  describe "#term" do
    it "should respond with 'term' from meta data (set by crawler)"
  end
  
  describe "#sanitized_description" do
    it "should sanitize the 'description' (clean HTML)"
  end

  describe "#origin_ts" do
    it "should be in UTC" do
      expect(post_event.origin_timestamp.zone).to eq "UTC"
    end
  end
end
