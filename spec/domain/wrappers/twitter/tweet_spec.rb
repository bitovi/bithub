require 'domain/wrappers/spec_helper'

describe Wrappers::Twitter::Tweet do

  let(:raw_tweet) do
    raw_data(response_path: 'twitter/status_event.json')
  end

  subject(:tweet) do
    Wrappers::Twitter::Tweet.new(raw_tweet)
  end
  
  # describe "#raw" do
  #   it "it should respond with raw data it was constructed with" do
  #     expect(tweet.raw).to eq raw_tweet.symbolize_keys
  #   end
  # end

  describe "#id" do
    it "should respond with 'id' from raw data" do
      expect(tweet.id).to eq raw_tweet['id']
    end
  end
  
  describe "#id_str" do
    it "should respond with 'id_str' from raw data" do
      expect(tweet.id_str).to eq raw_tweet['id_str']
    end
  end
  
  describe "#text" do
    it "should respond with 'text' from raw data" do
      expect(tweet.text).to eq raw_tweet['text']
    end
  end

end
