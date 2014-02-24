require 'domain/events/spec_helper'

describe Events::Github::IssueComment do

  let(:raw_issue_comment) do
    raw_data({response_path: 'github/events/issue_comment_event.json'})
  end
  
  let(:issue_comment_wrapper) do
    Wrappers::Github::Comment.new(raw_issue_comment['payload']['comment'])
  end

  subject(:issue_comment) do
    Events::Github::IssueComment.new(raw_issue_comment)
  end
  
  describe "#digest_seed" do
    it "should respond with digest seed constructed of event_id" do
      expect(issue_comment.digest_seed).to eq raw_issue_comment['id'] + "Events::Github::IssueComment"
    end
  end

  describe "#origin_id" do
    it "should delegate to @comment->#id" do
      expect(issue_comment.origin_id).to eq issue_comment_wrapper.id
    end
  end

end
