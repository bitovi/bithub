describe Evens::Feeds::Github::Types::CustomIssueEvent do
  let(:payload) { build_payload('github','push_event') }

  it_should_behave_like "every github event"
  it "creates Payload object with mapping methods" do
    expect(payload.push_id).to be_a(Integer)
  end
end
