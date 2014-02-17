describe Evens::Feeds::Github::Types::WatchEvent do
  let(:payload) {
    build_payload('github','watch_event', {response_path: 'github/events/watch_event.json'})
  }

  it_should_behave_like "every github event"
  #it "creates Payload object with mapping methods"
end

