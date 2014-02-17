describe Evens::Feeds::Github::Types::MemberEvent do
  let(:payload) {
    build_payload('github','member_event', {response_path: 'github/events/member_event.json'})
  }

  it_should_behave_like "every github event"
  it "creates Payload object with mapping methods" do
    expect(payload.member_name).to be_a(String)
  end
end
