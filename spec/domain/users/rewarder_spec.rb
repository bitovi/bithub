require 'domain/spec_helper'

RSpec.describe Users::Rewarder, :type => :domain do

  before :each do
    FactoryGirl.create(:reward, :title => 'small one', :point_minimum => 15)
    FactoryGirl.create(:reward, :title => 'big one', :point_minimum => 150)
    @rule = FactoryGirl.create(:scoring_rule, :authorship_value => 50)
    @user = FactoryGirl.create(:user, name: 'Nikica')
  end

  describe "#reward_if_eligible" do
    it "creates an achievement only for awards that have been achieved" do
      FactoryGirl.create(:determined_entity, :scoring_rule => @rule, :author => @user)
      
      Users::Rewarder.new(user: @user).reward_if_eligible
      expect(@user.achievements.count).to eql 1
    end
    
    it "creates an achievement only for rewards that are not already achieved (it is idenpotent)" do
      FactoryGirl.create(:determined_entity, :scoring_rule => @rule, :author => @user)
      
      Users::Rewarder.new(user: @user).reward_if_eligible
      Users::Rewarder.new(user: @user).reward_if_eligible
      expect(@user.achievements.count).to eql 1
    end
  end

  describe "#unreward_if_uneligible" do
    it "removes present achievements if user point total goes down" do
      entity = FactoryGirl.create(:determined_entity, :scoring_rule => @rule, :author => @user)
      Users::Rewarder.new(user: @user).reward_if_eligible
      entity.destroy

      expect {Users::Rewarder.new(user: @user).unreward_if_uneligible}.to change {@user.achievements.count}.from(1).to(0)
    end
  end

end
