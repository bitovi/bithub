require 'domain/events/spec_helper'

describe Events::Dispatcher do
  let(:event_persistor) { double("event_persistor") }
  let(:entity_persistor) { double("entity_persistor") }
  let(:rl) { ResponseLoader.new }
  
  subject(:dispatcher) { Events::Dispatcher.new(event_persistor, entity_persistor) }

  describe "#subtype" do
    context "when given a processed event" do
      it "should return the appropriate handler class" do
        expect(subject.subtype(rl.ppr('github', 'push_event'))).to            eq Events::Github::Push
        expect(subject.subtype(rl.ppr('github', 'pull_request_event'))).to    eq Events::Github::PullRequest
        expect(subject.subtype(rl.ppr('github', 'issue_comment_event'))).to   eq Events::Github::IssueComment
        expect(subject.subtype(rl.ppr('github', 'issues_event'))).to          eq Events::Github::Issue
        expect(subject.subtype(rl.ppr('github', 'commit_comment_event'))).to  eq Events::Github::CommitComment
        expect(subject.subtype(rl.ppr('forums', 'posts'))).to                 eq Events::Forum::Post
        expect(subject.subtype(rl.ppr('blog', 'posts'))).to                   eq Events::Blog::Post
        expect(subject.subtype(rl.ppr('disqus', 'comment_list'))).to          eq Events::Disqus::Post
        expect(subject.subtype(rl.ppr('twitter', 'status_event'))).to         eq Events::Twitter::Tweet
        expect(subject.subtype(rl.ppr('twitter', 'follow_event'))).to         eq Events::Twitter::Follow
      end
    end
  end
end
