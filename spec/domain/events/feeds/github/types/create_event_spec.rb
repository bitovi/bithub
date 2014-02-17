describe Evens::Feeds::Github::Types::CreateEvent do
  let(:payload) {
    build_payload('github','create_event', {response_path: 'github/events/create_event.json'})
  }

  it_should_behave_like "every github event"
  it_should_behave_like "every github event with refs"
  #it "creates Payload object with mapping methods"
end
