require 'domain/wrappers/spec_helper'

RSpec.describe Wrappers::Rss::Channel, :type => :domain do

  let(:raw_channel) do
    raw_data(response_path: 'forum/feed.rss').fetch('rss').fetch('channel')
  end
  
  subject(:channel) do
    Wrappers::Rss::Channel.new(raw_channel)
  end

  describe "#title" do
    it "should respond with 'title' from raw response" do
      expect(channel.title).to eq raw_channel['title']
    end
  end

  describe "#link" do
    it "should respond with 'link' from raw link" do
      expect(channel.link).to eq raw_channel['link']
    end
  end

  describe "#description" do
    it "should respond with 'description' from raw response" do
      expect(channel.description).to eq raw_channel['description']
    end
  end

end
