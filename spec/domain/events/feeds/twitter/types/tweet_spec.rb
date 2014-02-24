require 'domain/events/spec_helper'

describe Events::Twitter::Tweet do

  let(:raw_tweet) do
    raw_data(response_path: 'twitter/status_event.json')
  end
  
  subject(:tweet_wrapper) do
    Wrappers::Twitter::Tweet.new(raw_tweet)
  end

  subject(:tweet) do
    Events::Twitter::Tweet.new(raw_tweet)
  end

  describe "#origin_id" do
    it "should delegate to @tweet->#id_str" do
      expect(tweet.origin_id).to eq tweet_wrapper.id_str
    end
  end

  describe "#html_url" do
    it "should construct a url based on user's screen_name and tweet's id" do
      url = "https://twitter.com/#{raw_tweet['user']['screen_name']}/status/#{raw_tweet['id_str']}"
      expect(tweet.html_url).to eq url
    end
  end
  
  describe "#retweeted_status_id_str" do
    it "should respond with id_str of retweeted_status" do
      expect(tweet.retweet.id_str).to eq tweet_wrapper.retweeted_status.id_str
    end
  end

  describe "#origin_timestamp" do
    it "should be in UTC" do
      expect(tweet.origin_timestamp.zone).to eq "UTC"
    end
  end

end
