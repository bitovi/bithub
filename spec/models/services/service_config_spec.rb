require 'rails_helper'

describe Services::ServiceConfig do

  describe '#valid?' do
    
    it "rejects the config as invalid if the corresponding feed class doesn't exist" do
      config = { id: 12345677543 }

      sc = Services::ServiceConfig.new('qua?', 'group', config)
      expect(sc.valid?).to be false
      expect(sc.errors.first[:klass]).to eq(NameError)
    end

    it "rejects the config as invalid if the corresponding type class doesn't exist" do
      config = { id: 12345677543 }

      sc = Services::ServiceConfig.new('meetup', 'wat?', config)
      expect(sc.valid?).to be false
      expect(sc.errors.first[:klass]).to eq(NameError)
    end
    
    it 'rejects the config as invalid if it contains an unknown attribute' do
      config = {
        wat_qua: 'foo/bar',
      }

      sc = Services::ServiceConfig.new('github', 'repo', config)
      expect(sc.valid?).to be false
      expect(sc.errors.first[:klass]).to eq(Virtus::CoercionError)
    end

    it 'confirms that the config is valid' do
      config = {
        name: 'bitovi/canjs',
        tracking: { issues: true, pull_requests: false }
      }

      sc = Services::ServiceConfig.new('github', 'repo', config)
      expect(sc.valid?).to be true
    end
  end
end
