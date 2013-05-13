require 'spec_helper'

describe Identity do
  describe "#update_source_data_if_blank" do
    let(:oauth_data) { oauth_data_hash }

    it "should update the source_data with oauth_data" do
      identity = create(:identity, uid: oauth_data['uid'], provider: oauth_data['provider'] )
      identity.update_source_data_if_blank(oauth_data['info'])
      expect(identity.source_data).to eq(oauth_data['info'])
    end
  end

  describe ".find_or_create_with_oauth_data" do
    let(:oauth_data) { oauth_data_hash }

    context "when identity exists" do
      it "should find an existing identity" do
        existing_identity = create(:identity, uid: oauth_data['uid'], provider: oauth_data['provider'])
        identity = Identity.find_or_create_with_oauth_data(oauth_data)
        expect(identity).to eq(existing_identity)
      end
    end

    context "when identity does not exist" do
      it "should create a new identity" do
        identity = Identity.find_or_create_with_oauth_data(oauth_data)
        expect(identity).to be
      end
    end
  end
end
