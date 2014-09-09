require 'domain/wrappers/spec_helper'

RSpec.describe Wrappers::Disqus::Post, :type => :domain do

  let(:raw_post) do
    raw_data(response_path: 'disqus/comment_list.json')['response'].first
  end
  
  subject(:post) do
    Wrappers::Disqus::Post.new(raw_post)
  end

  describe "#id" do
    it "should respond with 'id' from raw response" do
      expect(post.id).to eq raw_post['id']
    end
  end

  describe "#url" do
    it "should respond with 'url' from raw response" do
      expect(post.url).to eq raw_post['url']
    end
  end

  describe "#message" do
    it "should respond with 'message' from raw response" do
      expect(post.message).to eq raw_post['message']
    end
  end

  describe "#created_at" do
    it "should be in UTC" do
      expect(post.created_at.zone).to eq "UTC"
    end

    it "should parse the 'created_at' unix created_atstamp from raw response" do
      parsed = Time.parse(raw_post.andand['createdAt']+'Z')
      expect(post.created_at).to eq parsed
    end
  end

end
