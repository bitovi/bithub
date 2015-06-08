require 'spec_helper'
require 'handlers/command_handler'
require_relative 'mock_listener'

describe CommandHandler do
  describe '#destruct' do
    it 'unpacks the information from the incoming packet' do
      eh = CommandHandler.new(MockListener.new)
      expect(eh.destruct({
        'meta' => {
          'brand_id' => 1,
          'service_id' => 3
        },
        'payload' => {
          'service' => {
            'id' => 1
          }
        }
      })).to eq([1, 3])
    end
  end
end
