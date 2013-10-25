require 'spec_helper'
require 'spec/processors/shared_specs'
require 'responses/responses'

require 'app/processor'

describe Processor do

  shared_examples_for "every Github event" do
    it_should_behave_like "every event"
    it "should have an event type in meta" do
      expect(processed_event[:meta][:type]).to be
    end
    it "should have :origin_id in meta" do
      expect(processed_event[:meta][:origin_id]).to be
    end
  end

  describe "#process" do

    context "when processing Github's" do

      def load_and_process(event_type)
        resp = Response.load('github', event_type)
        Processor.new('github').process(resp)
      end

      context "CommitCommentEvent" do
        let(:processed_event) { load_and_process('CommitCommentEvent') }

        it_should_behave_like "every Github event"
        it_should_behave_like "an event with a body and a url"
        it "should have a commit_id in meta" do
          expect(processed_event[:meta][:commit_id]).to be
        end
      end

      context "CreateEvent" do
        let(:processed_event) { load_and_process('CreateEvent') }
        it_should_behave_like "every Github event"
      end

      context "DeleteEvent" do
        let(:processed_event) { load_and_process('DeleteEvent') }
        it_should_behave_like "every Github event"
      end

      context "DownloadEvent" do
        let(:processed_event) { load_and_process('DownloadEvent') }
        it_should_behave_like "every Github event"
      end

      context "FollowEvent" do
        let(:processed_event) { load_and_process('FollowEvent') }
        it_should_behave_like "every Github event"
      end

      context "ForkEvent" do
        let(:processed_event) { load_and_process('ForkEvent') }
        it_should_behave_like "every Github event"
      end

      context "ForkApplyEvent" do
        let(:processed_event) { load_and_process('ForkApplyEvent') }
        it_should_behave_like "every Github event"
      end

      context "GistEvent" do
        let(:processed_event) { load_and_process('GistEvent') }
        it_should_behave_like "every Github event"
      end

      context "GollumEvent" do
        let(:processed_event) { load_and_process('GollumEvent') }
        it_should_behave_like "every Github event"
      end

      context "IssueCommentEvent" do
        let(:processed_event) { load_and_process('IssueCommentEvent') }

        it_should_behave_like "every Github event"
        it_should_behave_like "an event with a body and a url"
        it "should have an issue_id in meta" do
          expect(processed_event[:meta][:issue_id]).to be
        end
      end

      context "IssuesEvent" do
        let(:processed_event) { load_and_process('IssuesEvent') }

        it_should_behave_like "every Github event"
        it_should_behave_like "an event with a body and a url"
        it "should have :labels in meta" do
          expect(processed_event[:meta][:labels]).to be
        end
        it "should have a :state in meta" do
          expect(processed_event[:meta][:state]).to be
        end
        it "should have an :issue_id in meta" do
          expect(processed_event[:meta][:issue_id]).to be
        end
        it "should have an :action in meta" do
          expect(processed_event[:meta][:action]).to be
        end
      end

      context "MemberEvent" do
        let(:processed_event) { load_and_process('MemberEvent') }
        it_should_behave_like "every Github event"
      end

      context "PublicEvent" do
        let(:processed_event) { load_and_process('PublicEvent') }
        it_should_behave_like "every Github event"
      end

      context "PullRequestEvent" do
        let(:processed_event) { load_and_process('PullRequestEvent') }

        it_should_behave_like "every Github event"
        it_should_behave_like "an event with a body and a url"
      end

      context "PullRequestReviewCommentEvent" do
        let(:processed_event) { load_and_process('PullRequestReviewCommentEvent') }
        it_should_behave_like "every Github event"
      end

      context "WatchEvent" do
        let(:processed_event) { load_and_process('WatchEvent') }
        it_should_behave_like "every Github event"
      end

      context "PushEvent" do
        let(:processed_event) { load_and_process('PushEvent') }

        it_should_behave_like "every Github event"
        it "should have an url" do
          expect(processed_event[:url]).to be
        end
        it "should have :commits in meta" do
          expect(processed_event[:meta][:commits]).to be
        end
      end

      context "TeamAddEvent" do
        let(:processed_event) { load_and_process('TeamAddEvent') }
        it_should_behave_like "every Github event"
      end

      context "WatchEvent" do
        let(:processed_event) { load_and_process('WatchEvent') }
        it_should_behave_like "every Github event"
      end
    end
  end
end
