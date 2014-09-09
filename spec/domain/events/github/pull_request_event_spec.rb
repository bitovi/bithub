require 'domain/events/spec_helper'

describe Events::Github::PullRequestEvent do

  let(:raw_pull_request) do
    raw_data(response_path: 'github/events/pull_request_event.json')
  end
  
  subject(:pull_request) do
    Events::Github::PullRequestEvent.new(raw_pull_request).wrap_response
  end

  describe "#digest_seed" do
    it "should construct the digest seed from event_id" do
      seed = raw_pull_request['id'] + "Events::Github::PullRequestEvent"
      expect(pull_request.digest_seed).to eq seed
    end
  end
end
