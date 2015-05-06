require 'rails_helper'

describe Entities::Tumblr::Video do
  describe 'data' do
    it 'prepares the data for building/updating' do
      post_event = Events::Tumblr::Post.new(
        raw_data(response_path: 'tumblr/tagged.json')['response'][0])

      entity_wrapper = Entities::Tumblr::Video.new(post_event)
      instance = entity_wrapper.procure.instance

      expect(instance.attributes.keys).to include('title', 'body', 'url', 'origin_id', 'origin_ts')
      expect(instance.props.keys).to include('tags', 'origin_author_name')
    end
  end
end
