
describe Evens::Feeds::Github::Types::PushEvent do
  let(:payload) {
    build_payload('github','push_event', {response_path: 'github/events/push_event.json'})
  }

  it_should_behave_like "every github event"
  it "creates Payload object with mapping methods" do
    expect(payload.push_id).to be_a(Integer)
    expect(payload.commits.length).to eq(1)
    expect(payload.commit_shas.length).to eq(1)
    expect(payload.commit_messages.length).to eq(1)
    expect(payload.commit_shas_csv).to be_a(String)
    expect(payload.referenced_repo_name).to be_a(String)
    expect(payload.head).to be_a(String)

    # SHOULD IT RETURN JUST AN INT OR PREFIXED WITH #
    #expect(payload.referenced_number).to be_a(String)
  end
end
