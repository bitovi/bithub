require 'domain/events/spec_helper'

describe Events::Forum::Post do
    
  let(:raw_forum_post) do
    raw_data(response_path: 'forum/posts.rss')['rss']['channel']['item'].first
  end

  subject(:forum_post) do
    Events::Forum::Post.new(raw_forum_post)
  end

  describe "#content_digest" do
    it "should calculate the digest using 'link' and class name" do
      seed = raw_forum_post['link'] + "Events::Forum::Post"
      expect(forum_post.digest_seed).to eq seed
    end
  end

  describe "#title" do
    it "should respond with 'title' from raw response" do
      expect(forum_post.title).to eq raw_forum_post['title']
    end
  end
  
  describe "#description" do
    it "should respond with 'description' from raw response" do
      expect(forum_post.description).to eq raw_forum_post['description']
    end
  end
  
  describe "#sanitized_description" do
    it "should sanitize the 'description' (clean HTML)"
  end

  describe "#url" do
    it "should delegate to #link" do
      expect(forum_post.url).to eq forum_post.link
    end
  end

  describe "#link" do
    it "shoul respond with 'link' from raw response" do
      expect(forum_post.link).to eq raw_forum_post['link']
    end
  end
  
  describe "#origin_author_name" do
    it "should respond with 'dc:creator' from raw response" do
      expect(forum_post.origin_author_name).to eq raw_forum_post['dc:creator']
    end
  end
  
  describe "#subforum" do
    it "should delegate to #category" do
      expect(forum_post.subforum).to eq forum_post.category
    end
  end

  describe "#category" do
    it "should respond with 'category' field from raw response"
  end
  
  describe "#term" do
    it "should respond with 'term' from meta data (set by crawler)"
  end

  describe "#origin_ts" do
    it "should respond with time-parsed 'pubDate' from raw response" do
      parsed_time = Time.parse(raw_forum_post.andand['pubDate']).utc
      expect(forum_post.origin_ts).to eq parsed_time
    end

    it "should be in UTC" do
      expect(forum_post.origin_ts.zone).to eq "UTC"
    end
  end
end
