require 'domain/events/spec_helper'

describe Events::Forum::Post do
    
  let(:raw_forum_post) do
    raw_data('forum','post')
  end

  subject(:forum_post) do
    Events::Forum::Post.new(raw_forum_post)
  end

  describe "#content_digest" do
    it "should calculate the digest using 'link' and class name" do
      digest = Digest::MD5.hexdigest(raw_forum_post['link'] + raw_forum_post.class.name)
      expect(forum_post.content_digest).to eq digest
    end
  end

  describe "#title" do
    it "should equal NEKO POLJE from raw post"
  end
  
  describe "#description" do
    it "should equal NEKO POLJE from raw post"
  end
  
  describe "#sanitized_description" do
    it "should equal NEKO POLJE from raw post"
  end

  describe "#url" do
    it "should delegate to #link"
  end

  describe "#link" do
    it "should equal NEKO POLJE from raw post"
  end
  
  describe "#origin_author_name" do
    it "should equal NEKO POLJE from raw post"
  end
  
  describe "#subforum" do
    it "should equal NEKO POLJE from raw post"
  end
  
  describe "#term" do
    it "should equal NEKO POLJE from meta"
  end

  describe "#origin_author_name" do
    it "should be in UTC"
  end


  # it "creates Event object with mapping methods" do
  #   expect(event.title).to be_a(String)
  #   expect(event.body).to be_a(String)
  #   expect(event.link).to be_a(String)
  #   expect(event.subforum).to be_a(String)
  #   expect(event.origin_author_name).to be_a(String)
  #   expect(event.origin_timestamp).to be_a(Date)
  # end    

end
