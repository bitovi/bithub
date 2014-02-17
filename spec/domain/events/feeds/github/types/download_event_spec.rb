describe Evens::Feeds::Github::Types::DownloadEvent do
  let(:payload) {
    build_payload('github','download_event', {response_path: 'github/events/download_event.json'})
  }

  it_should_behave_like "every github event"
  it "creates Payload object with mapping methods" do
    expect(payload.name).to be_a(String)
    expect(payload.description).to be_a(String)
    expect(payload.url).to be_a(String)
  end
end
