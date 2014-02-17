describe Evens::Feeds::Github::Types::ForkApplyEvent do
  let(:payload) {
    build_payload('github','fork_apply_event', {response_path: 'github/events/fork_apply_event.json'})
  }

  it_should_behave_like "every github event"
  #it "creates Payload object with mapping methods"
end
