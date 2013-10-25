require 'spec_helper'
require 'spec/processors/shared_specs'
require 'responses/responses'

require 'app/processor'

describe Processor do

  shared_examples_for "every Twitter event" do
    it_should_behave_like "every event"

    it "should generates a unique hash key" do
      expect(processed_event[:hash_key].length).to eq(32)
    end

    it "has a :type in meta" do 
      expect(processed_event[:meta][:type]).to be
    end

    it "should have an :origin_author_id in meta" do
      expect(processed_event[:meta][:origin_author_id]).to be
    end

    it "should have an :origin_author_name in meta" do
      expect(processed_event[:meta][:origin_author_name]).to be
    end
  end

  shared_examples_for "every tweet" do
    it "should have an URL" do
      expect(processed_event[:url]).to be
    end

    it "should have :tweet_id in meta" do
      expect(processed_event[:meta][:tweet_id]).to be
    end

    it "should have :origin_id in meta" do
      expect(processed_event[:meta][:origin_id]).to be
    end
  end

  describe "#process" do

    context "when processing Twitter's user stream" do

      def load_and_process(event_type)
        resp = Response.load('twitter', event_type)
        Processor.new('twitter') do |config|
          config[:is_user_stream] = true
        end.process(resp)
      end

      context "status_events" do
        it "should reject it" # maybe fail ?
      end

      context "follow_events" do
        let(:processed_event) { load_and_process('follow_event') }

        it_should_behave_like "every Twitter event"
        it "should have a source"
        it "should have a target"
      end
    end

    context "when processing Twitter's public stream" do

      def load_and_process(event_type)
        resp = Response.load('twitter', event_type)
        Processor.new('twitter') do |config|
          config[:is_user_stream] = false
        end.process(resp)
      end

      context "tweets (status_events)" do
        let(:processed_event) { load_and_process('status_event') }

        it_should_behave_like "every Twitter event"
        it_should_behave_like "every tweet"
      end

      context "retweets (status_events)" do
        let(:processed_event) { load_and_process('status_event_rt') }

        it_should_behave_like "every Twitter event"
        it_should_behave_like "every tweet"

        it "should be a retweet" do
          expect(processed_event[:meta][:retweeted_id]).to be        
        end
      end
    end
  end
end
