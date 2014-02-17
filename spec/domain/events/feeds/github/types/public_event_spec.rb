describe Evens::Feeds::Github::Types::PublicEvent do
  let(:payload) {
    build_payload('github','public_event', {response_path: 'github/events/public_event.json'})
  }

  it_should_behave_like "every github event"
  #it "creates Payload object with mapping methods"
end
