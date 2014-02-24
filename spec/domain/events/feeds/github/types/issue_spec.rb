require 'domain/events/spec_helper'

describe Events::Github::Issue do

  let(:raw_issue) {
    raw_data(response_path: 'github/events/issues_event.json')
  }
  
  let(:issue_wrapper) do
    Wrappers::Github::Issue.new(raw_issue['payload']['issue'])
  end

  subject(:issue) do
    Events::Github::Issue.new(raw_issue)
  end

  describe "#digest_seed" do
    it "should construct the digest seed from event_id" do
      seed = raw_issue['id'] + "Events::Github::Issue"
      expect(issue.digest_seed).to eq seed
    end
  end

  describe "#body" do
    it "should delegate to @issue->#body" do
      expect(issue.body).to eq issue_wrapper.body
    end
  end

end
