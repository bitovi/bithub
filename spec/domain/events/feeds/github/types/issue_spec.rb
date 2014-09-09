require 'domain/events/spec_helper'

describe Events::Github::Issue do

  let(:raw_issue) {
    raw_data(response_path: 'github/events/issues_event.json')
  }

  subject(:issue) do
    Events::Github::Issue.new(raw_issue).wrap_response
  end

  describe "#digest_seed" do
    it "should construct the digest seed from event_id" do
      seed = raw_issue['id'] + "Events::Github::Issue"
      expect(issue.digest_seed).to eq seed
    end
  end

end
