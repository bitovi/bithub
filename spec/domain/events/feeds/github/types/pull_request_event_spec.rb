describe Evens::Feeds::Github::Types::PullRequestEvent do
  let(:payload) {
    build_payload('github','pull_request_event', {response_path: 'github/events/pull_request_event.json'})
  }

  it_should_behave_like "every github event"
  it_should_behave_like "every github issues or pull requests event"
  #it "creates Payload object with mapping methods"
end
