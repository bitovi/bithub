require 'domain/events/spec_helper'

describe Events::Disqus::Post do
  
  let(:raw_post) do
    raw_data(response_path: 'disqus/comment_list.json')['response'].first
  end
  
  subject(:post_event) do
    Events::Disqus::Post.new(raw_post)
  end
  
  describe "#content_digest" do
    it "should calculate the digest using 'post_id' and class name" do
      seed = raw_post['id'] + "Events::Disqus::Post"
      expect(post_event.digest_seed).to eq seed
    end
  end

  describe "#origin_id" do
    it "should delegate to @post->#id" do
      expect(post_event.origin_id).to eq post_wrapper.id
    end
  end

  describe "#title" do
    it "should delegate to @thread->#title" do
      expect(post_event.title).to eq thread_wrapper.title
    end
  end

  describe "#origin_author_name" do
    it "should delegate to @author->#author_name" do
      expect(post_event.origin_author_name).to eq author_wrapper.name
    end
  end

  describe "#origin_timestamp" do
    it "should be in UTC" do
      expect(post_event.origin_timestamp.zone).to eq "UTC"
    end

    it "should parsing to @post->#created_at" do
      expect(post_event.origin_timestamp).to eq post_wrapper.created_at.utc
    end
  end

  # Delegates
  let(:post_wrapper) do
    Wrappers::Disqus::Post.new(raw_post)
  end

  let(:thread_wrapper) do
    Wrappers::Disqus::Thread.new(raw_post['thread'])
  end
  
  let(:author_wrapper) do
    Wrappers::Disqus::Author.new(raw_post['author'])
  end

end
