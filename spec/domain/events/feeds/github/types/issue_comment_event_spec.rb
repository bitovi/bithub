describe Evens::Feeds::Github::Types::DownloadEvent do
  let(:payload) {
    build_payload('github','issue_comment_event', {response_path: 'github/events/issue_comment_event.json'})
  }

  it_should_behave_like "every github event"
  it_should_behave_like "every github comment event"
  #it_should_behave_like "every github issues or pull requests event"
  it_should_behave_like "every github event with labels"
  #it "creates Payload object with mapping methods"
end
