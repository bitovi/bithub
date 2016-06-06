require 'rails_helper'

describe Bits::Disqus::Post do
  describe 'data' do
    it 'prepares the data for building/updating' do
      post_event = Events::Disqus::PostEvent.new(
        raw_data(response_path: 'disqus/comment_list.json')['response'][1])

      bit_wrapper = Bits::Disqus::Post.new(post_event)
      instance = bit_wrapper.procure.instance

      expect(instance.attributes.keys).to include('title', 'body', 'url', 'origin_id', 'origin_ts')
      expect(instance.props.keys).to include('origin_author_id', 'origin_author_name')
    end
  end
end
