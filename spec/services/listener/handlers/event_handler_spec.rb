require 'spec_helper'
require 'handlers/event_handler'
require_relative 'mock_listener'

describe EventHandler do
  describe '#destruct' do
    it 'unpacks the information from the incoming packet' do
      eh = EventHandler.new(MockListener.new)
      expect(eh.destruct({
        'meta' => {
          'brand_name' => 'bicikl',
          'embed_name' => 'kamo ide',
          'feed_name' => 'tko zna kamo',
          'type_name' => 'ide'
        },
        'payload' => { }
      })).to eq(['bicikl', 'kamo ide', 'tko zna kamo', 'ide'])

    end
  end
end

