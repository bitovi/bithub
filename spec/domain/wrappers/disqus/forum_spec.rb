require 'domain/wrappers/spec_helper'

describe Wrappers::Disqus::Forum do

  let(:raw_forum) do
    raw_data(response_path: 'disqus/comment_list.json')['response'].first['forum']
  end
  
  subject(:forum) do
    Wrappers::Disqus::Forum.new(raw_forum)
  end

  describe "#id" do
    it "should respond with 'id' from raw response" do
      expect(forum.id).to eq raw_forum['id']
    end
  end

  describe "#url" do
    it "should respond with 'url' from raw response" do
      expect(forum.url).to eq raw_forum['url']
    end
  end

  describe "#name" do
    it "should respond with 'name' from raw response" do
      expect(forum.name).to eq raw_forum['name']
    end
  end

end
