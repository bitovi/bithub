require 'domain/events/spec_helper'

describe Events::Blog::Post do

  let(:raw_blog_post) do
    raw_data(response_path: 'blog/posts.rss')['rss']['channel']['item'].first
  end

  subject(:blog_post) do
    Events::Blog::Post.new(raw_blog_post)
  end

  describe "#digest_seed" do
    it "should calculate the digest using 'link' and class name" do
      seed = raw_blog_post['link'] + "Events::Blog::Post"
      expect(blog_post.digest_seed).to eq seed
    end
  end

  describe "#link" do
    it "should respond with 'link' from raw response" do
      expect(blog_post.link).to eq raw_blog_post['link']
    end
  end

  describe "#title" do
    it "should respond with 'title' from raw response" do
      expect(blog_post.title).to eq raw_blog_post['title']
    end
  end

  describe "#description" do
    it "should respond with 'description' from raw response" do
      expect(blog_post.description).to eq raw_blog_post['description']
    end
  end

  describe "#origin_timestamp" do
    it "should respond with time-parsed 'published' from raw response" do
      parsed_date = Time.strptime(raw_blog_post['published'], "%e %b %Y")
      expect(blog_post.origin_timestamp).to eq(parsed_date)
    end

    it "should resopnd with a datetime in UTC" do
      expect(blog_post.origin_timestamp.zone).to eq "UTC"
    end
  end
end
