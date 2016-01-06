require 'services/guzzler/spec_helper'
require 'guzzler/digests'

describe Guzzler::Digests do

  before(:each) do
    Guzzler.redis { |c| c.flushdb }
  end

  describe '#reject_old' do
    it 'rejects' do

      f = Guzzler::Digests.new
      meta = { meta: { tenant_name: 'mirko', service_id: 1 } }

      first_batch = [
        { content_digest: 'abc'}.merge(meta),
        { content_digest: 'def'}.merge(meta),
        { content_digest: 'ghi'}.merge(meta)
      ]

      second_batch = [
        { content_digest: 'ghi' }.merge(meta),
        { content_digest: 'jkl' }.merge(meta)
      ]
      
      new_items = [
        { content_digest: 'jkl' }.merge(meta)
      ]

      f.reject_old(first_batch)
      expect(f.reject_old(second_batch)).to eq(new_items)
    end
  end

  describe '#key_total' do
    it 'calcs1' do
      d = Guzzler::Digests.new

      expect(d.key_total({
        content_digest: 'jkl',
        meta: { tenant_name: 'mirko', service_id: 1 }
      })).to eq('digests:total:mirko:1')
    end
  end
  
  describe '#key_batch' do
    it 'calcs1' do
      d = Guzzler::Digests.new

      expect(d.key_batch({
        content_digest: 'jkl',
        meta: { tenant_name: 'mirko', service_id: 1 }
      })).to eq('digests:batch:mirko:1')
    end
  end
end
