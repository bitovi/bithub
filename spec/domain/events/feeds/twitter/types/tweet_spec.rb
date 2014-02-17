describe Events::Feeds::Twitter::Types::Tweet do

  let(:payload) { build_payload('twitter','follow', {response_path: 'twitter/follow_event.json'}) }

  it_should_behave_like "every twitter event"
  it "creates Payload object with mapping methods" do
    expect(payload.source).to be_a(Hash)
    expect(payload.source_id).to be_a(Integer)
    expect(payload.source_screen_name).to be_a(String)
    expect(payload.target).to be_a(Hash)
    expect(payload.target_id).to be_a(Integer)
    expect(payload.target_screen_name).to be_a(String)
  end
end
