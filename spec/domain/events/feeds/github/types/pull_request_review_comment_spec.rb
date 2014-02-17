describe Evens::Feeds::Github::Types::PullRequestReviewCommentEvent do
  let(:payload) {
    build_payload('github','pull_request_review_comment_event', {response_path: 'github/events/pull_request_review_comment_event.json'})
  }

  it_should_behave_like "every github event"
  it_should_behave_like "every github comment event"
  #it "creates Payload object with mapping methods"
end
