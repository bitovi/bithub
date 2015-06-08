require 'spec_helper'
require 'handlers/error_handler'
require_relative 'mock_listener'

describe ErrorHandler do
  describe '#destruct' do
    it 'unpacks the information from the incoming packet' do
      eh = ErrorHandler.new(MockListener.new)
      expect(eh.destruct({
        'meta' => {
          'brand_id' => 1
        },
        'error' => {
          'klass' => 'SomeError',
          'message' => 'whadap'
        }
      })).to eq([1, {
          'klass' => 'SomeError',
          'message' => 'whadap'
        }, 'SomeError'])
    end
  end
end
