require 'domain/entities/spec_helper'

describe Entities::Twitter::Tweet do

  def build_tweet(attrs={})
    payload = double()
    payload.stub(:feed => "twitter")
    payload.stub(:type => "tweet")
    payload.stub(:tweet_id => attrs[:tweet_id] || "1234567")
    payload.stub(:text => attrs[:text] || "160 character tweet text")
    payload.stub(:html_url => attrs[:html_url] || "http://twitter.com/foobar")
    payload.stub(:origin_author_id => attrs[:origin_author_id] || "123")
    payload.stub(:origin_author_name => attrs[:origin_author_name] || "canjs")
    payload.stub(:original_tweet_id => attrs[:original_tweet_id] || nil)
    payload.stub(:retweet? => attrs[:text] || false)
    payload.stub(:origin_ts => attrs[:origin_ts] || Time.now)
    Entities::Twitter::Tweet.new(payload).procure
  end

  tweet = {text: "tweet", tweet_id: "12345"}
  retweet = {text: "retweet", tweet_id: "12346", original_tweet_id: "12345", retweet?: true}
  retweet2 = {text: "another retweet", tweet_id: "12347", original_tweet_id: "12345", retweet?: true}
  another_tweet = {text: "another tweet", tweet_id: "12348"}

  describe "#build" do
    it "instances new Entity object" do
      entity = build_tweet(tweet)
      entity.determine
      entity.persist!

      expect(entity.instance.title).to be_a(String)
      expect(entity.instance.url).to be_a(String)
      expect(entity.instance.origin_ts).to be_a(Time)
      expect(entity.instance.thread_updated_ts).to be_a(Time)
      expect(entity.instance.feed_name).to eq("twitter")
      expect(entity.instance.type_name).to eq("tweet")
      expect(entity.instance.props['origin_author_id']).to be_a(String)
      expect(entity.instance.props['origin_author_name']).to be_a(String)
      expect(entity.instance.props['retweeted_id']).to be_nil
      
      expect(entity.procure_children.length).to eq(0)
      expect(entity.procure_parent).to be_nil
    end
  end

  describe "#procure_*" do
    it "checks for parents and children" do
      rt = build_tweet(retweet); rt.determine; rt.persist!
      tw = build_tweet(tweet); tw.determine; tw.persist!
      rt2 = build_tweet(retweet2); rt2.determine; rt2.persist!
      atw = build_tweet(another_tweet); atw.determine; atw.persist!

      expect(tw.procure_children.length).to eq(2)
      expect(rt.procure_parent.id).to eq(tw.instance.id)
      expect(rt2.procure_parent.id).to eq(tw.instance.id)
      expect(atw.procure_parent).to be_nil
      expect(atw.procure_children.length).to eq(0)
    end
  end

end

describe Entities::Twitter::Follow do
  def build_follow
    payload = double()
    payload.stub(:feed => "twitter")
    payload.stub(:type => "follow")
    payload.stub(:origin_ts => Time.now)
    payload.stub(:source_id => "123")
    payload.stub(:source_screen_name => "foobar")
    payload.stub(:target_screen_name => "canjs")
    Entities::Twitter::Follow.new(payload).procure    
  end

  describe "#build" do
    it "instances new Entity object" do
      entity = build_follow
      entity.determine
      entity.persist!

      expect(entity.instance.title).to be_a(String)
      expect(entity.instance.origin_ts).to be_a(Time)
      expect(entity.instance.feed_name).to eq('twitter')
      expect(entity.instance.type_name).to eq('follow')
      expect(entity.instance.props['origin_author_id']).to be_a(String)
      expect(entity.instance.props['origin_author_name']).to be_a(String)
    end
  end      

end
