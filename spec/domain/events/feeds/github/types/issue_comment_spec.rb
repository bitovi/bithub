require 'domain/events/spec_helper'

describe Events::Github::IssueComment do

  let(:raw_issue_comment) do
    raw_data({response_path: 'github/events/issue_comment.json'})
  end

  subject(:issue_comment) do
    Events::Github::IssueComment.new(raw_issue_comment)
  end
  
  pending "add some tests"

end
