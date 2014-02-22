require 'domain/wrappers/spec_helper'

describe Wrappers::Disqus::Thread do

  let(:raw_thread) do
    raw_data(response_path: 'disqus/comment_list.json')['response'].first['thread']
  end
  
  subject(:thread) do
    Wrappers::Disqus::Thread.new(raw_thread)
  end

  describe "#id" do
    it "should respond with 'id' from raw response" do
      expect(thread.id).to eq raw_thread['id']
    end
  end

  describe "#title" do
    it "should respond with 'title' from raw response" do
      expect(thread.title).to eq raw_thread['title']
    end
  end

  describe "#link" do
    it "should respond with 'link' from raw response" do
      expect(thread.link).to eq raw_thread['link']
    end
  end

  describe "#created_at" do
    it "should parse the 'created_at' unix created_atstamp from raw response" do
      parsed = Time.parse(raw_thread.andand['createdAt']+'Z')
      expect(thread.created_at).to eq parsed
    end
  end

end

