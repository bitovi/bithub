require 'rails_helper'

describe Services::ServiceConfig do

  describe '#valid?' do
    it 'returns true if config is valid' do
      config = {
        name: 'foo/bar',
        tracking: { issues: true, pull_requests: false }
      }

      sc = Services::ServiceConfig.new('github', 'repo', config)
      expect(sc.valid?).to be true
    end

    it 'returns false and records errors if config is invalid' do
      config = {
        name: 'foo/bar',
        tracking: { issues: true } # pull_req attr is missing
      }

      sc = Services::ServiceConfig.new('github', 'repo', config)
      expect(sc.valid?).to eq false
      expect(sc.errors.first[:type]).to eq(:coercion)
      expect(sc.errors.first[:attr]).to eq(:pull_requests)
    end

    it 'returns false and records errors if validator is missing' do
      sc = Services::ServiceConfig.new('unknown', 'feed/type', {})
      expect(sc.valid?).to eq false
      expect(sc.errors.first[:type]).to eq(:validator)
    end
  end

end
