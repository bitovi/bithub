require 'domain/events/spec_helper'

describe Events::Disqus::Post do
  
  let(:raw_disqus_post) do
    raw_data(response_path: 'disqus/comment_list.json')['response'].first
  end

  subject(:disqus_post) do
    Events::Disqus::Post.new(raw_disqus_post)
  end
  
  describe "#content_digest" do
    it "should calculate the digest using 'post_id' and class name" do
      digest = Digest::MD5.hexdigest(raw_disqus_post['id'] + disqus_post.class.name)
      expect(disqus_post.content_digest).to eq digest
    end
  end

  describe "#origin_id" do
    it "should delegate to post_id" do
      expect(disqus_post.origin_id).to eq disqus_post.post_id
    end
  end

  describe "#post_id" do
    it "should respond with 'id' from raw response" do
      expect(disqus_post.post_id).to eq raw_disqus_post['id']
    end
  end

  describe "#title" do
    it "should delegate to #thread_title" do
      expect(disqus_post.title).to eq disqus_post.thread_title
    end
  end

  describe "#thread_title" do
    it "should respond with 'thread'->'title' from raw response" do
      expect(disqus_post.thread_title).to eq raw_disqus_post['thread']['title']
    end
  end
  
  describe "#message" do
    it "should respond with 'message' form raw response" do
      expect(disqus_post.message).to eq raw_disqus_post['message']
    end
  end

  describe "#url" do
    it "should respond with 'url' from raw response" do
      expect(disqus_post.url).to eq raw_disqus_post['url']
    end
  end

  describe "#author_name" do
    it "should respond with 'author'->'name' from raw response" do
      expect(disqus_post.author_name).to eq raw_disqus_post['author']['name']
    end
  end

  describe "#origin_author_name" do
    it "should delegate to #author_name" do
      expect(disqus_post.origin_author_name).to eq disqus_post.author_name
    end
  end

  describe "#origin_timestamp" do
    it "should be in UTC" do
      expect(disqus_post.origin_timestamp.zone).to eq "UTC"
    end

    it "should respond with time-parsed 'createdAt' from raw response" do
      parsed_time = Time.parse(raw_disqus_post.andand['createdAt']+'Z').utc
      expect(disqus_post.origin_timestamp).to eq parsed_time
    end
  end

end
