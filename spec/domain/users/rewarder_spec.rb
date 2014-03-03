require 'domain/spec_helper'

describe Users::Rewarder do
  describe "#reward_if_eligible" do
    it "should create one achievement for each award that the user is eligible for"
    it "should create an achievement only for rewards that are not already achievement/present"
    it "doesn't create duplicate achievements"
  end
end
