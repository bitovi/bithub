require 'domain/wrappers/spec_helper'

describe Wrappers::Github::PullRequest do

  let(:raw_pull_request) do
    raw_data(response_path: 'github/events/pull_request_event.json')['payload']['pull_request']
  end

  subject(:pull_request) do
    Wrappers::Github::PullRequest.new(raw_pull_request)
  end
  
  # describe "#raw" do
  #   it "it should respond with raw data it was constructed with" do
  #     expect(pull_request.raw).to eq raw_pull_request.symbolize_keys
  #   end
  # end

end
