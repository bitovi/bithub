require 'domain/spec_helper'

describe Users::PointAwarder do

  describe "#completed_profile?" do
    it "responds with false if all profile fields have not been filled" do
      user = FactoryGirl.build(:user)
      expect(Users::PointAwarder.new(user).completed_profile?).to be_false
    end

    it "responds with true if all profile fields have been filled" do
      user = FactoryGirl.build(:user, :with_completed_profile)
      expect(Users::PointAwarder.new(user).completed_profile?).to be_true
    end
  end
  
  describe "#award_points_for_linking" do
    it "awards 1 point for singning in with OAuth for the first time" do
      user = FactoryGirl.create(:user)
      Users::PointAwarder.new(user).award_points_for_linking('twitter')
      expect(user.score).to eq 1
    end
  end
  
  describe "#award_points_for_completing_profile" do
    it "awards 1 point for completing profile" do
      user = FactoryGirl.create(:user, :with_completed_profile)
      Users::PointAwarder.new(user).award_points_for_completing_profile
      expect(user.score).to eq 1
    end
  end

end
