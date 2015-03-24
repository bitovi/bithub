require 'rails_helper'

describe Services::ServiceConfig do

  describe '#valid?' do
    
    it "rejects the config as invalid if the corresponding feed class doesn't exist" do
      service = FactoryGirl.build(:facebook_service, feed_name: 'why')
      sc = Services::ServiceConfig.new(service)

      expect(sc.valid?).to be false
      expect(sc.errors.first[:klass]).to eq(NameError)
    end

    it "rejects the config as invalid if the corresponding type class doesn't exist" do
      service = FactoryGirl.build(:meetup_service, type_name: 'what')
      sc = Services::ServiceConfig.new(service)

      expect(sc.valid?).to be false
      expect(sc.errors.first[:klass]).to eq(NameError)
    end
    
    it 'rejects the config as invalid if it contains an unknown attribute' do
      service = FactoryGirl.build(:github_service, :invalid)
      sc = Services::ServiceConfig.new(service)

      expect(sc.valid?).to be false
      expect(sc.errors.first[:klass]).to eq(Virtus::CoercionError)
    end

    it 'confirms that the config is valid' do
      service = FactoryGirl.build(:github_service)
      sc = Services::ServiceConfig.new(service)

      expect(sc.valid?).to be true
    end
  end
end
