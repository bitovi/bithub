require 'rails_helper'

describe Bits::Facebook::Photo do
  describe 'data' do
    it 'prepares the data for building/updating' do
      photo_event = Events::Facebook::PhotoEvent.new(
        raw_data(response_path: 'facebook/feed.json')[1])

      bit_wrapper = Bits::Facebook::Photo.new(photo_event)
      instance = bit_wrapper.procure.instance

      expect(instance.attributes.keys).to include('title', 'body', 'url', 'origin_ts', 'origin_id')
      expect(instance.props.keys).to include('origin_object_id', 'photos', 'origin_author_id', 'origin_author_name')
    end
  end
end
