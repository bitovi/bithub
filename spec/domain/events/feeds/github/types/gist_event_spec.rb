describe Evens::Feeds::Github::Types::GistEvent do
  let(:payload) {
    build_payload('github','gist_event', {response_path: 'github/events/gist_event.json'})
  }

  it_should_behave_like "every github event"
  it "creates Payload object with mapping methods" do
    expect(payload.action).to be_a(String)
    expect(payload.html_url).to be_a(String)
    expect(payload.description).to be_a(String)
  end
end
