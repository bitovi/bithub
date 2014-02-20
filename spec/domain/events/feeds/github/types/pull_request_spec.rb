require 'domain/events/spec_helper'

describe Events::Github::PullRequest do

  let(:raw_pull_request) do
    raw_data(response_path: 'github/events/pull_request_event.json')
  end

  subject(:pull_request) do
    Events::Github::PullRequest.new(raw_pull_request)
  end

  pending "add some tests"

end
