require 'domain/events/spec_helper'

describe Events::Twitter::Tweet do

  let(:raw_tweet) do
    raw_data(response_path: 'twitter/status_event.json')
  end

  subject(:tweet) do
    Events::Twitter::Tweet.new(raw_tweet)
  end

  describe "#origin_id" do
    it "should delegate to #tweet_id_str" do
      expect(tweet.origin_id).to eq tweet.tweet_id_str
    end
  end

  describe "tweet_id" do
    it "should respond with 'id' from raw response" do
      expect(tweet.tweet_id).to eq raw_tweet['id']
    end
  end

  describe "tweet_id_str" do
    it "should respond with 'id_str' from raw response" do
      expect(tweet.tweet_id_str).to eq raw_tweet['id_str']
    end
  end

  describe "text" do
    it "should respond with 'text' from raw response" do
      expect(tweet.text).to eq raw_tweet['text']
    end
  end

  describe "user_id" do
    it "should respond with 'user'->'id' from raw response" do
      expect(tweet.user_id).to eq raw_tweet['user']['id']
    end
  end
  
  describe "user_screen_name" do
    it "should respond with 'user'->'screen_name' from raw response" do
      expect(tweet.user_screen_name).to eq raw_tweet['user']['screen_name']
    end
  end

  describe "user_profile_image_url" do
    it "should respond with 'user'->'profile_image_url' from raw response" do
      expect(tweet.user_profile_image_url).to eq raw_tweet['user']['profile_image_url']
    end
  end
  
  describe "retweet?" do
    it "should respond positively if the tweet is a retweet" do
      expect(tweet.retweet?).to eq not(raw_tweet['retweeted_status'].nil?)
    end
  end

  describe "html_url" do
    it "should construct a url based on user's screen_name and tweet's id" do
      url = "https://twitter.com/#{raw_tweet['user']['screen_name']}/status/#{raw_tweet['id']}"
      expect(tweet.html_url).to eq url
    end
  end
  
  # --- Aliases
  describe "original_tweet_id" do
    it "should delegate to 'retweeted_status_id'" do
      expect(tweet.original_tweet_id).to eq tweet.retweeted_status_id
    end
  end
  
  describe "original_tweet_id_str" do
    it "should delegate to 'retweeted_status_id_str'" do
      expect(tweet.original_tweet_id_str).to eq tweet.retweeted_status_id_str
    end
  end

end
