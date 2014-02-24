require 'domain/wrappers/spec_helper'

describe Wrappers::Twitter::Tweet do

  let(:raw_tweet) do
    raw_data(response_path: 'twitter/status_event.json')
  end

  subject(:tweet) do
    Wrappers::Twitter::Tweet.new(raw_tweet)
  end

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
  
  describe "#created_at" do
    it "should respond with time-parsed 'created_at' from raw data" do
      expect(tweet.created_at).to eq Time.parse(raw_tweet['created_at'])
    end
  end
  
  describe "retweet?" do
    it "should respond positively if the tweet is a retweet" do
      expect(tweet.retweet?).to eq not(raw_tweet['retweeted_status'].nil?)
    end
  end
  
  describe "retweeted_status" do
    it "should be access the retweeted status data" do
      retweet = Wrappers::Twitter::Tweet.new(raw_tweet['retweeted_status'])
      expect(tweet.retweeted_status.text).to eq retweet.text
    end
  end


end
