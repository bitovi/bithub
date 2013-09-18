require 'spec_helper'
require 'digest/md5'
require 'responses/responses.rb'

describe Handler::Github do

  shared_examples_for "every Github event" do

    it_should_behave_like "every event"

    #it "generates unique hash key"

    it "has some meta proporties" do 
      expect(@prepared[:meta][:type]).to be
      expect(@prepared[:meta][:origin_id]).to be
    end
  end

  context "upon fetching Github event" do

    before :all do
      @githubProcessor = EventProcessor::Github.new
    end
    
    def load_and_prepare(type)
      @event = Response.load('github',type)
      @githubProcessor.process(@event)
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

    describe "#prepare_event (CreateEvent)" do
      before do
        @prepared = load_and_prepare('CreateEvent')
      end

      it_should_behave_like "every Github event"
    end

    describe "#prepare_event (DeleteEvent)" do
      before do
        @prepared = load_and_prepare('DeleteEvent')
      end

      it_should_behave_like "every Github event"
    end

    describe "#prepare_event (DownloadEvent)" do
      before do
        @prepared = load_and_prepare('DownloadEvent')
      end

      it_should_behave_like "every Github event"
    end

    describe "#prepare_event (FollowEvent)" do
      before do
        @prepared = load_and_prepare('FollowEvent')
      end

      it_should_behave_like "every Github event"
    end

    describe "#prepare_event (ForkEvent)" do
      before do
        @prepared = load_and_prepare('ForkEvent')
      end

      it_should_behave_like "every Github event"
    end

    describe "#prepare_event (ForkApplyEvent)" do
      before do
        @prepared = load_and_prepare('ForkApplyEvent')
      end

      it_should_behave_like "every Github event"
    end

    describe "#prepare_event (GistEvent)" do
      before do
        @prepared = load_and_prepare('GistEvent')
      end

      it_should_behave_like "every Github event"
    end

    describe "#prepare_event (GollumEvent)" do
      before do
        @prepared = load_and_prepare('GollumEvent')
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

    describe "#prepare_event (MemberEvent)" do
      before do
        @prepared = load_and_prepare('MemberEvent')
      end

      it_should_behave_like "every Github event"
    end

    describe "#prepare_event (PublicEvent)" do
      before do
        @prepared = load_and_prepare('PublicEvent')
      end

      it_should_behave_like "every Github event"
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

    describe "#prepare_event (PullRequestReviewCommentEvent)" do
      before do
        @prepared = load_and_prepare('PullRequestReviewCommentEvent')
      end

      it_should_behave_like "every Github event"
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

    describe "#prepare_event (TeamAddEvent)" do
      before do
        @prepared = load_and_prepare('TeamAddEvent')
      end

      it_should_behave_like "every Github event"
    end

    describe "#prepare_event (WatchEvent)" do
      before do
        @prepared = load_and_prepare('WatchEvent')
      end

      it_should_behave_like "every Github event"
    end
    
  end

end
