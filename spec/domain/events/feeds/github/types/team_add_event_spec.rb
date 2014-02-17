describe Evens::Feeds::Github::Types::TeamAddEvent do
  let(:payload) {
    build_payload('github','team_add_event', {response_path: 'github/events/team_add_event.json'})
  }

  it_should_behave_like "every github event"
  #it "creates Payload object with mapping methods"
end
