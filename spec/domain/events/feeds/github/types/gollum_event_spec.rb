describe Evens::Feeds::Github::Types::GollumEvent do
  let(:payload) {
    build_payload('github','gollum_event', {response_path: 'github/events/gollum_event.json'})
  }

  it_should_behave_like "every github event"
  it "creates Payload object with mapping methods" do
    expect(payload.pages).to be_a(Array)
    expect(payload.page_titles).to be_a(Array)
    expect(payload.page_urls).to be_a(Array)
  end
end
