require 'domain/entities/spec_helper'

describe Entities::Dispatcher do

  describe "#dispatch" do

    context "dispatching something with feed 'forums'" do
    end

    context "dispatching a CustomIssue event" do
    end

    context "dispatching a CustomWatch event" do
    end

    context "dispatching a CustomIssueComment event" do
    end

    context "dispatching a CustomFollow event" do
    end


    context "dispatching PullRequest event" do
      it "responds with PullRequest" do
        raw = raw_data(response_path: 'github/events/issues_event.json')
        event = Events::Github::PullRequest.new(raw).wrap_reponse
        expect(Entities::Dispatcher.new(event).type).to eq Entities::Github::PullRequest
      end

      context "with action != opened" do
        it "responds with IssueAction if action != opened" do
          raw = raw_data(response_path: 'github/events/issues_event.json')
          raw['payload']['action'] = 'reopened'
          event = Events::Github::PullRequest.new(raw).wrap_reponse
          expect(Entities::Dispatcher.new(event).type).to eq Entities::Github::IssueAction
        end
      end
    end

    context "dispatching Issue" do
      it "responds with Issue" do
        raw = raw_data(response_path: 'github/events/pull_request_event.json')
        event = Events::Github::Issue.new(raw).wrap_reponse
        expect(Entities::Dispatcher.new(event).type).to eq Entities::Github::Issue
      end

      context "action != opened" do
        it "responds with IssueAction if action != opened" do
          raw = raw_data(response_path: 'github/events/pull_request_event.json')
          raw['payload']['action'] = 'closed'
          event = Events::Github::Issue.new(raw).wrap_reponse
          expect(Entities::Dispatcher.new(event).type).to eq Entities::Github::IssueAction
        end
      end
    end

  end
end
