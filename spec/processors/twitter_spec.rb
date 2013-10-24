require 'spec_helper'
require 'spec/processors/shared_specs'

require 'app/processor'
require 'responses/responses'

describe Processor do
  let(:feed) { 'twitter' }

  shared_examples_for "every Twitter event" do
    it_should_behave_like "every event"

    it "should generates a unique hash key" do
      expect(processed_event[:hash_key].length).to eq(32)
    end

    it "has some meta proporties" do 
      expect(processed_event[:meta][:type]).to be
      expect(processed_event[:meta][:origin_author_name]).to be
      expect(processed_event[:meta][:origin_author_id]).to be
    end
  end

  context "when processing user stream" do
    let(:processor) do
      Processor.new(feed) do |config|
        config[:is_user_stream] = true
      end
    end

    context "status_event events" do
      it "should reject it" # maybe fail ?
    end

    context "follow_event events" do
      let(:processed_event) { processor.process(Response.load(feed, 'follow_event')) }

      describe "#process" do
        it_should_behave_like "every Twitter event"
        it "should have a source"
        it "should have a target"
      end
    end
  end

  context "public stream events" do
    let(:processor) do
      Processor.new(feed) do |config|
        config[:is_user_stream] = false
      end
    end

    context "processing a tweet" do
      let(:processed_event) { processor.process(Response.load(feed, 'status_event')) }

      describe "#process" do
        it_should_behave_like "every Twitter event"

        it "has an URL" do
          expect(processed_event[:url]).to be
        end

        it "has :tweet_id in meta" do
          expect(processed_event[:meta][:tweet_id]).to be
        end

        it "has :origin_id in meta" do
          expect(processed_event[:meta][:origin_id]).to be
        end
      end
    end

    context "processing a retweet" do
      let(:processed_event) { processor.process(Response.load(feed, 'status_event_rt')) }

      it_should_behave_like "every Twitter event"

      it "has additional attributes" do
        expect(processed_event[:url]).to be
        expect(processed_event[:meta][:tweet_id]).to be
        expect(processed_event[:meta][:origin_id]).to be
      end

      it "is retweet" do
        expect(processed_event[:meta][:retweeted_id]).to be        
      end
    end
  end
end
