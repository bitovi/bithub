describe Evens::Feeds::Github::Types::IssuesEvent do
  let(:payload) {
    build_payload('github','issues_event', {response_path: 'github/events/issues_event.json'})
  }

  it_should_behave_like "every github event"
  it_should_behave_like "every github issues or pull requests event"
  it_should_behave_like "every github event with labels"
  #it "creates Payload object with mapping methods"
end
