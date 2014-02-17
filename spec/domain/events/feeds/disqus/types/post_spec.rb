require 'domain/events/spec_helper.rb'

describe Events::Feeds::Disqus::Types::Post do

  describe "#initialize" do
    raw_response = load_response('spec/support/responses/disqus/comment_list.json')
    comment = raw_response['response'].first

    let(:payload) { Events::Dispatcher.dispatch(comment, 'disqus') }

    it_should_behave_like "every event"
    it "creates Payload object with mapping methods" do
      expect(payload.post_id).not_to be_empty
      expect(payload.thread).not_to be_empty
      expect(payload.title).not_to be_empty
      expect(payload.message).not_to be_empty
      expect(payload.url).not_to be_empty
      expect(payload.origin_author_name).not_to be_empty
      expect(payload.origin_ts).to be_a(Time)
    end        
  end
end
