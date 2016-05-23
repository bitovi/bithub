require 'rails_helper'

describe Bits::Tumblr::Photo do
  describe 'data' do
    it 'prepares the data for building/updating' do
      post_event = Events::Tumblr::PostEvent.new(
        raw_data(response_path: 'tumblr/tagged.json')['response'][1])

      bit_wrapper = Bits::Tumblr::Photo.new(post_event)
      instance = bit_wrapper.procure.instance

      expect(instance.attributes.keys).to include('title', 'body', 'url', 'origin_id', 'origin_ts')
      expect(instance.props.keys).to include('tags', 'origin_author_name', 'photos')
    end
  end
end
