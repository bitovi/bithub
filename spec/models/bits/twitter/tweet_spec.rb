require 'rails_helper'

describe Bits::Twitter::Tweet do
  describe 'data' do
    it 'prepares the data for building/updating' do
      status_event = Events::Twitter::TweetEvent.new(
        raw_data(response_path: 'twitter/status_event.json'))

      bit_wrapper = Bits::Twitter::Tweet.new(status_event)
      instance = bit_wrapper.procure.instance

      expect(instance.attributes.keys).to include('title', 'url', 'origin_ts', 'origin_id')
      expect(instance.props.keys).to include('origin_author_id', 'origin_author_name', 'origin_author_avatar_url', 'entities_urls', 'entities_media') # 'origin_author_username'
    end
  end
end
