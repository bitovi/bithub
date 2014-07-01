require 'domain/wrappers/spec_helper'

RSpec.describe Wrappers::Disqus::Author, :type => :domain do

  let(:raw_author) do
    raw_data(response_path: 'disqus/comment_list.json')['response'][5]['author']
  end
  
  subject(:author) do
    Wrappers::Disqus::Author.new(raw_author)
  end
  
  describe "#id" do
    it "should respond with 'id' from raw response" do
      expect(author.id).to eq raw_author['id']
    end
  end

  describe "#name" do
    it "should respond with 'name' from raw response" do
      expect(author.name).to eq raw_author['name']
    end
  end

  describe "#username" do
    it "should respond with 'username' from raw response" do
      expect(author.username).to eq raw_author['username']
    end
  end
end
