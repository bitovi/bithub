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
