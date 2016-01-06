require 'services/guzzler/spec_helper'
require 'guzzler/publisher'

describe Guzzler::Digests do

  before(:each) do
    Guzzler.redis { |c| c.flushdb }
  end

  describe '#publish' do
    it 'publishes to a FIFO queue' do
      push left prvi
      push left drugi

      prvi mora izac na prvi pop right
      drugi mora izac na drugi pop right
    end
  end
end
