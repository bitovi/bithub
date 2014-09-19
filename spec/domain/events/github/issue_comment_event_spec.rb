require 'domain/events/spec_helper'

describe Events::Github::IssueCommentEvent do

  let(:raw_issue_comment) do
    raw_data({response_path: 'github/events/issue_comment_event.json'})
  end
  
  subject(:issue_comment) do
    Events::Github::IssueCommentEvent.new(raw_issue_comment).wrap_response
  end
  
  describe "#digest_seed" do
    it "should respond with digest seed constructed of event_id" do
      expect(issue_comment.digest_seed).to eq raw_issue_comment['id'] + "Events::Github::IssueCommentEvent"
    end
  end

end
