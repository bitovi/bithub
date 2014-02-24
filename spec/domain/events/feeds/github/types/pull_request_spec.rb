require 'domain/events/spec_helper'

describe Events::Github::PullRequest do

  let(:raw_pull_request) do
    raw_data(response_path: 'github/events/pull_request_event.json')
  end
  
  subject(:pull_request_wrapper) do
    Wrappers::Github::PullRequest.new(raw_pull_request['payload']['pull_request'])
  end

  subject(:pull_request) do
    Events::Github::PullRequest.new(raw_pull_request)
  end

  describe "#digest_seed" do
    it "should construct the digest seed from event_id" do
      seed = raw_pull_request['id'] + "Events::Github::PullRequest"
      expect(pull_request.digest_seed).to eq seed
    end
  end

  describe "#body" do
    it "should delegate to @pull_request->#body" do
      expect(pull_request.body).to eq pull_request_wrapper.body
    end
  end

end
