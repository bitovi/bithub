describe Evens::Feeds::Github::Types::CommitCommentEvent do
  let(:payload) {
    build_payload('github','commit_comment_event', {response_path: 'github/events/commit_comment_event.json'})
  }

  it_should_behave_like "every github event"
  it_should_behave_like "every github comment event"

  it "creates Payload object with mapping methods" do
    expect(payload.commit_id).to be_a(String)
  end
end
