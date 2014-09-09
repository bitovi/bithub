require 'domain/entities/spec_helper'

describe Entities::Dispatcher do

  describe "#dispatch" do

    context "when dispatching Twitter events" do

      context "specifically a TweetEvent" do
        it "responds with Tweet entity" do
          raw = raw_data(response_path: 'twitter/status_event.json')
          event = Events::Twitter::TweetEvent.new(raw)
          expect(Entities::Dispatcher.new(event).type).to eq Entities::Twitter::Tweet
        end
      end
      
      context "specifically a FakeFollowEvent" do
        it "responds with Follow entity" do
          raw = raw_data(response_path: 'twitter/fake_follow_event.json')
          event = Events::Twitter::FakeFollowEvent.new(raw)
          expect(Entities::Dispatcher.new(event).type).to eq Entities::Twitter::Follow
        end
      end
    end

    context "when dispatching Github events" do

      context "specifically an Issue from Issues API endpoint" do
        it "responds with PullRequest entity" do
          raw = raw_data(response_path: 'github/issues/issues.json').first
          event = Events::Github::CustomIssueEvent.new(raw)
          expect(Entities::Dispatcher.new(event).type).to eq Entities::Github::Issue
        end
      end

      context "specifically a PullRequestEvent" do
        it "responds with PullRequest entity" do
          raw = raw_data(response_path: 'github/events/issues_event.json')
          event = Events::Github::PullRequestEvent.new(raw)
          expect(Entities::Dispatcher.new(event).type).to eq Entities::Github::PullRequest
        end

        context "with action != opened" do
          it "responds with IssueAction entity if action != opened" do
            raw = raw_data(response_path: 'github/events/issues_event.json')
            raw['payload']['action'] = 'reopened'
            event = Events::Github::PullRequestEvent.new(raw)
            expect(Entities::Dispatcher.new(event).type).to eq Entities::Github::IssueAction
          end
        end
      end

      context "specifically an IssueEvent" do
        it "responds with Issue entity" do
          raw = raw_data(response_path: 'github/events/pull_request_event.json')
          event = Events::Github::IssueEvent.new(raw)
          expect(Entities::Dispatcher.new(event).type).to eq Entities::Github::Issue
        end

        context "action != opened" do
          it "responds with IssueAction entity if action != opened" do
            raw = raw_data(response_path: 'github/events/pull_request_event.json')
            raw['payload']['action'] = 'closed'
            event = Events::Github::IssueEvent.new(raw)
            expect(Entities::Dispatcher.new(event).type).to eq Entities::Github::IssueAction
          end
        end
      end
      
      context "specifically a CustomIssue event" do
      end

      context "specifically a CustomWatch event" do
      end

      context "specifically a CustomIssueComment event" do
      end

      context "specifically a CustomFollow event" do
      end
    end

  end
end
