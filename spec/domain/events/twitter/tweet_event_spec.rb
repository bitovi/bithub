require 'domain/events/spec_helper'

describe Events::Twitter::TweetEvent do

  let(:raw_tweet) do
    raw_data(response_path: 'twitter/status_event.json')
  end
  
  subject(:tweet_wrapper) do
    Wrappers::Twitter::Tweet.new(raw_tweet)
  end
  
  subject(:tweet) do
    Events::Twitter::TweetEvent.new(raw_tweet)
  end

  describe "#html_url" do
    it "constructs a url based on user's screen_name and tweet's id" do
      url = "https://twitter.com/#{raw_tweet['user']['screen_name']}/status/#{raw_tweet['id_str']}"
      expect(tweet.html_url).to eq url
    end
  end
  
  describe "#retweet" do
    it "responds with retweeted_status if available" do
      expect(tweet.retweet.id_str).to eq tweet_wrapper.retweeted_status.id_str
    end
  end

end
