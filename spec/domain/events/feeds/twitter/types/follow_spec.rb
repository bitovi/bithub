describe Events::Feeds::Twitter::Types::Tweet do

  let(:payload) { build_payload('twitter','tweet', {response_path: 'twitter/status_event.json'}) }

  it_should_behave_like "every twitter event"
  it "creates Payload object with mapping methods" do
    expect(payload.origin_id).to be_a(String)
    expect(payload.text).to be_a(String)
    expect(payload.user).to be_a(Hash)
    expect(payload.origin_author_id).to be_a(Integer)
    expect(payload.origin_author_name).to be_a(String)

    #expect(payload.html_url).to be_a()
    #expect(payload.retweeted_status).to be_a()
    #expect(payload.original_tweet_id).to be_a()
    #expect(payload.retweet?).to be_a()
  end
end
