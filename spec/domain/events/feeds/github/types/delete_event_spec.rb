describe Evens::Feeds::Github::Types::DeleteEvent do
  let(:payload) {
    build_payload('github','delete_event', {response_path: 'github/events/delete_event.json'})
  }

  it_should_behave_like "every github event"
  it_should_behave_like "every github event with refs"
  # it "creates Payload object with mapping methods"
end
