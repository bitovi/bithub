require 'spec_helper'
require 'digest/md5'
require 'responses/responses.rb'

describe Handler::Github do

  shared_examples_for "every Github event" do
    it "has title" do
      expect(@prepared[:title]).to be
    end

    it "parses timestamp" do
      expect(@prepared[:origin_ts]).to be
      expect(@prepared[:origin_date]).to be
    end

    #it "generates unique hash key"

    it "has some meta proporties" do 
      expect(@prepared[:meta]).to be
      expect(@prepared[:meta][:type]).to be
      expect(@prepared[:meta][:feed]).to be
      expect(@prepared[:meta][:origin_id]).to be
    end

    it "has source data" do
      expect(@prepared[:source_data]).to be
    end

  end

  context "upon fetching Github event" do

    def load_and_prepare(type)
      @event = Response.load('github',type)
      Handler::Github.prepare_event(@event, {:feed => 'github'})
    end

    describe "#prepare_event (CommitCommentEvent)" do
      before do
        @prepared = load_and_prepare('CommitCommentEvent')
      end

      it_should_behave_like "every Github event"

      it "has body and url" do
        expect(@prepared[:body]).to be
        expect(@prepared[:url]).to be
      end

      it "has commit id in meta" do
        expect(@prepared[:meta][:commit_id]).to be
      end
    end

    describe "#prepare_event (DeleteEvent)" do
      before do
        @prepared = load_and_prepare('DeleteEvent')
      end

      it_should_behave_like "every Github event"
    end

    describe "#prepare_event (ForkEvent)" do
      before do
        @prepared = load_and_prepare('ForkEvent')
      end

      it_should_behave_like "every Github event"
    end

    describe "#prepare_event (IssueCommentEvent)" do
      before do
        @prepared = load_and_prepare('IssueCommentEvent')
      end

      it_should_behave_like "every Github event"

      it "has body and url" do
        expect(@prepared[:body]).to be
        expect(@prepared[:url]).to be
      end

      it "has issue id in meta" do
        expect(@prepared[:meta][:issue_id]).to be
      end
    end

    describe "#prepare_event (IssuesEvent)" do
      before do
        @prepared = load_and_prepare('IssuesEvent')
      end

      it_should_behave_like "every Github event"

      it "has body and url" do
        expect(@prepared[:body]).to be
        expect(@prepared[:url]).to be
      end

      it "has additional meta attrs" do
        expect(@prepared[:meta][:labels]).to be
        expect(@prepared[:meta][:state]).to be
        expect(@prepared[:meta][:issue_id]).to be
        expect(@prepared[:meta][:action]).to be
      end
    end

    describe "#prepare_event (PullRequestEvent)" do
      before do
        @prepared = load_and_prepare('PullRequestEvent')
      end

      it_should_behave_like "every Github event"

      it "has body and url" do
        expect(@prepared[:body]).to be
        expect(@prepared[:url]).to be
      end      
    end

    describe "#prepare_event (WatchEvent)" do
      before do
        @prepared = load_and_prepare('WatchEvent')
      end

      it_should_behave_like "every Github event"
    end

    describe "#prepare_event (PushEvent)" do
      before do
        @prepared = load_and_prepare('PushEvent')
      end

      it_should_behave_like "every Github event"

      it "has url" do
        expect(@prepared[:url]).to be
      end

      it "has commits in meta" do
        expect(@prepared[:meta][:commits]).to be
      end
    end

    describe "#prepare_event (CreateEvent)" do
      before do
        @prepared = load_and_prepare('CreateEvent')
      end

      it_should_behave_like "every Github event"
    end
    
  end

end
