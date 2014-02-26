require 'domain/wrappers/spec_helper'

describe Wrappers::Rss::Item do

  let(:raw_item) do
    raw_data(response_path: 'forum/feed.rss').fetch('rss').fetch('channel').fetch('item').first
  end
  
  subject(:item) do
    Wrappers::Rss::Item.new(raw_item)
  end

  describe "#title" do
    it "should respond with 'title' from raw response" do
      expect(item.title).to eq raw_item['title']
    end
  end

  describe "#link" do
    it "should respond with 'link' from raw link" do
      expect(item.link).to eq raw_item['link']
    end
  end

  describe "#description" do
    it "should respond with 'description' from raw response" do
      expect(item.description).to eq raw_item['description']
    end
  end

  describe "#category" do
    it "should parse the 'category' unix categorystamp from raw response" do
      expect(item.category).to eq raw_item['category']
    end
  end
  
  describe "#pub_date" do
    it "should time-parse the 'pubDate' from raw response" do
      parsed = Time.parse(raw_item['pubDate'])
      expect(item.pub_date).to eq parsed
    end
  end

end
