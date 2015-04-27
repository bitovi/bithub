require 'rails_helper'

describe Entities::Facebook::Photo do
  describe 'data' do
    it 'prepares the data for building/updating' do
      photo_event = Events::Facebook::PhotoEvent.new(
        raw_data(response_path: 'facebook/feed.json')[1])

      entity_wrapper = Entities::Facebook::Photo.new(photo_event)

      expect(entity_wrapper.data.keys).to include(
        :title, :body, :url, :origin_ts, :origin_id)

      expect(entity_wrapper.data[:props].keys).to include(
        :origin_object_id, :photos,
        :origin_author_id, :origin_author_name)
    end
  end
end
