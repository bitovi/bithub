require 'domain/events/spec_helper'

describe Events::Disqus::PostEvent do
  
  let(:raw_post) do
    raw_data(response_path: 'disqus/comment_list.json')['response'].first
  end
  
  subject(:post_event) do
    Events::Disqus::PostEvent.new(raw_post)
  end
  
  describe "#content_digest" do
    it "should calculate the digest using 'post_id' and class name" do
      seed = raw_post['id'] + "Events::Disqus::PostEvent"
      expect(post_event.digest_seed).to eq seed
    end
  end

end
