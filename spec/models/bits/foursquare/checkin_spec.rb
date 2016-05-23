require 'rails_helper'

describe Bits::Foursquare::Checkin do
  describe 'data' do
    it 'prepares the data for building/updating' do
      raw = JSON.parse(CGI.parse(File.read('spec/support/responses/foursquare/checkin_postback'))['checkin'][0])
      checkin_event = Events::Foursquare::CheckinEvent.new(raw)
      bit_wrapper = Bits::Foursquare::Checkin.new(checkin_event)

      expect(bit_wrapper.data.keys).to include(
        :title, :origin_id, :origin_ts)

      expect(bit_wrapper.data[:props].keys).to include(
        :origin_author_id, :origin_author_name,
        :venue_id, :venue_name)
    end
  end
end
