require 'models/wrappers/spec_helper'

RSpec.describe Wrappers::Twitter::Bits, :type => :domain do

  let(:raw_bits) do
    raw_data(response_path: 'twitter/status_event.json')['bits']
  end

  subject(:bits) do
    Wrappers::Twitter::Bits.new(raw_bits)
  end
  
  describe "#urls" do
    it "should respond with 'urls' from raw data" do
      urls = raw_bits['urls'].andand.map {|url| url.andand.symbolize_keys!}
      expect(bits.urls).to eq urls
    end
  end
  
  describe "#symbols" do
    it "should respond with 'symbols' from raw data" do
      symbols = raw_bits['symbols'].andand.map {|sym| sym.andand.symbolize_keys!}
      expect(bits.symbols).to eq symbols
    end
  end
  
  describe "#hashtags" do
    it "should respond with 'hashtags' from raw data" do
      hashtags = raw_bits['hashtags'].andand.map {|ht| ht.andand.symbolize_keys!}
      expect(bits.hashtags).to eq hashtags
    end
  end

  describe "#user_mentions" do
    it "should respond with 'user_mentions' from raw data" do
      user_mentions = raw_bits['user_mentions'].andand.map {|um| um.andand.symbolize_keys!}
      expect(bits.user_mentions).to eq user_mentions
    end
  end

end
