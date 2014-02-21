require 'domain/wrappers/spec_helper'

describe Wrappers::Twitter::Entities do

  let(:raw_entities) do
    raw_data(response_path: 'twitter/status_event.json')['entities']
  end

  subject(:entities) do
    Wrappers::Twitter::Entities.new(raw_entities)
  end
  
  # describe "#raw" do
  #   it "it should respond with raw data it was constructed with" do
  #     expect(entities.raw).to eq raw_entities.symbolize_keys
  #   end
  # end

  describe "#urls" do
    it "should respond with 'urls' from raw data" do
      urls = raw_entities['urls'].map {|url| url.symbolize_keys!}
      expect(entities.urls).to eq urls
    end
  end
  
  describe "#symbols" do
    it "should respond with 'symbols' from raw data" do
      symbols = raw_entities['symbols'].map {|sym| sym.symbolize_keys!}
      expect(entities.symbols).to eq symbols
    end
  end
  
  describe "#hashtags" do
    it "should respond with 'hashtags' from raw data" do
      hashtags = raw_entities['hashtags'].map {|ht| ht.symbolize_keys!}
      expect(entities.hashtags).to eq hashtags
    end
  end

  describe "#user_mentions" do
    it "should respond with 'user_mentions' from raw data" do
      user_mentions = raw_entities['user_mentions'].map {|um| um.symbolize_keys!}
      expect(entities.user_mentions).to eq user_mentions
    end
  end

end
