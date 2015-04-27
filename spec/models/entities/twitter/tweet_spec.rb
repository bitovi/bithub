require 'rails_helper'

describe Entities::Twitter::Tweet do
  describe 'data' do
    it 'prepares the data for building/updating' do
      status_event = Events::Twitter::TweetEvent.new(
        raw_data(response_path: 'twitter/status_event.json'))

      entity_wrapper = Entities::Twitter::Tweet.new(status_event)

      expect(entity_wrapper.data.keys).to include(
        :title, :url, :origin_ts, :origin_id)

      expect(entity_wrapper.data[:props].keys).to include(
        :origin_author_id, :origin_author_name,
        :origin_author_username, :origin_author_avatar_url,
        :entities_urls, :entities_media)
    end
  end
end
