require 'domain/wrappers/spec_helper'

RSpec.describe Wrappers::Rss::Item, :type => :domain do

  let(:raw_item) do
    raw_data(response_path: 'forum/feed.rss').fetch('rss').fetch('channel').fetch('item').first
  end

  subject(:item) do
    Wrappers::Rss::Item.new(raw_item)
  end

  describe "#title" do
    it "responds with 'title' from raw response" do
      expect(item.title).to eq raw_item['title']
    end
  end

  describe "#link" do
    it "responds with 'link' from raw link" do
      expect(item.link).to eq raw_item['link']
    end
  end

  describe "#description" do
    it "responds with 'description' from raw response" do
      expect(item.description).to eq raw_item['description']
    end
  end

  describe "#category" do
    it "responds with 'category' from raw response" do
      expect(item.category).to eq raw_item['category']
    end
  end

  describe "#pub_date" do
    it "is in UTC" do
      expect(item.published.zone).to eq "UTC"
    end

    it "should time-parse the 'pubDate' from raw response" do
      parsed = Time.parse(raw_item['pubDate'])
      expect(item.published).to eq parsed
    end
  end

end
