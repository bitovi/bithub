require 'spec_helper'
require 'digest/md5'
require 'responses/responses.rb'

describe Handler::Twitter do

  shared_examples_for "every Twitter event" do

    it_should_behave_like "every event"

    it "generates unique hash key" do
      expect(@prepared[:hash_key].length).to eq(32)
    end

    it "has some meta proporties" do 
      expect(@prepared[:meta][:type]).to be
      expect(@prepared[:meta][:origin_author_name]).to be
      expect(@prepared[:meta][:origin_author_id]).to be
    end
  end

  context "upon fetching Twitter event" do

    describe "#prepare_event (User event)" do
      before do
        @event = Response.load('twitter', 'follow_event')
        @prepared = Handler::Twitter.prepare_user_event(@event, {:feed => 'twitter'})
      end

      it_should_behave_like "every Twitter event"
    end

    describe "#prepare_event (Public event)" do
      before do
        @event = Response.load('twitter', 'status_event')
        @prepared = Handler::Twitter.prepare_public_event(@event, {:feed => 'twitter'})
      end

      it_should_behave_like "every Twitter event"

      it "has additional attributes" do
        expect(@prepared[:url]).to be
        expect(@prepared[:meta][:tweet_id]).to be
        expect(@prepared[:meta][:origin_id]).to be
      end
    end

    describe "#prepare_event (Public event RT)" do
      before do
        @event = Response.load('twitter', 'status_event_rt')
        @prepared = Handler::Twitter.prepare_public_event(@event, {:feed => 'twitter'})
      end

      it_should_behave_like "every Twitter event"

      it "has additional attributes" do
        expect(@prepared[:url]).to be
        expect(@prepared[:meta][:tweet_id]).to be
        expect(@prepared[:meta][:origin_id]).to be
      end
      
      it "is retweet" do
        expect(@prepared[:meta][:retweeted_id]).to be        
      end

    end
    
  end
end
