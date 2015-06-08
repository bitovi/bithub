require 'spec_helper'
require 'handlers/event_handler'
require_relative 'mock_listener'

describe EventHandler do
  describe '#destruct' do
    it 'unpacks the information from the incoming packet' do
      eh = EventHandler.new(MockListener.new)
      expect(eh.destruct({
        'meta' => {
          'brand_id' => 1,
          'embed_id' => 2,
          'service_id' => 3
        },
        'payload' => { }
      })).to eq([1, 2, 3])

    end
  end
end
