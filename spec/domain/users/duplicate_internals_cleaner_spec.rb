require 'domain/spec_helper'

RSpec.describe Users::DuplicateInternalsCleaner, :type => :domain do

  before do
    @user = FactoryGirl.create(:user)
    @i1 = FactoryGirl.create(:internal, value: 10, comment: 'duplicate', receiver: @user)
  end

  subject(:cleaner) { Users::DuplicateInternalsCleaner.new(@user) }

  describe "#duplicates" do
    it "returns duplicate internals" do
      i2 = FactoryGirl.build(:internal, value: 5, comment: 'duplicate', receiver: @user)
      i2.save(:validate => false)
      expect(cleaner.duplicates).to eq [i2]
    end
  end

  describe "#clean" do
    it "returns a truthy value if there were duplicate internals" do
      i2 = FactoryGirl.build(:internal, value: 5, comment: 'duplicate', receiver: @user)
      i2.save(:validate => false)
      expect(cleaner.clean).to be_truthy
    end

    it "returns a falsy if there were no duplicate internals" do
      expect(cleaner.clean).to be_falsey
    end
  end

end
