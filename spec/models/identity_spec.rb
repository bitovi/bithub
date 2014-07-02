require 'spec_helper'

RSpec.describe Identity, :type => :model do
  describe "#update_source_data_if_blank" do
    before (:all) { Identity.delete_all }
    let(:oauth_data) { oauth_data_hash }

    it "should update the source_data with oauth_data" do
      identity = FactoryGirl.create(:identity, uid: oauth_data['uid'], provider: oauth_data['provider'] )
      identity.update_source_data_if_blank(oauth_data['info'])
      expect(identity.source_data).to eq(oauth_data['info'])
    end
  end

  describe ".find_or_create_with_provider_and_uid" do
    context "when identity exists" do
      it "should find an existing identity" do
        existing_identity = FactoryGirl.create(:identity, uid: 123456789, provider: 'twitter')
        identity = Identity.find_or_create_with_provider_and_uid('twitter', 123456789)
        expect(identity).to eq(existing_identity)
      end
    end

    context "when identity does not exist" do
      it "should create a new identity" do
        identity = Identity.find_or_create_with_provider_and_uid('twitter', 123456789)
        expect(identity).to be
      end
    end
  end

end
