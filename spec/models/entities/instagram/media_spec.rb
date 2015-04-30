require 'rails_helper'

describe Entities::Instagram::Media do
  describe 'data' do
    it 'prepares the data for building/updating' do
      media_event = Events::Instagram::MediaEvent.new(
        raw_data(response_path: 'instagram/media.json'))

      entity_wrapper = Entities::Instagram::Media.new(media_event)
      instance = entity_wrapper.procure.instance

      expect(instance.attributes.keys).to include('title', 'url', 'origin_ts', 'origin_id')
      expect(instance.props.keys).to include('origin_author_id', 'origin_author_name', 'origin_author_avatar_url', 'image_url') # 'origin_author_username'
    end
  end
end
