require 'spec_helper'

describe Reward do
  before :each do
    @author = create(:user, name: "Nikica")
    @actor = create(:user, name: "Veljko")
    @rule = create(:rule, upvote_value: 155)
    @event = create(:event_determined, rule: @rule, author: @author, title: "Event in reward_spec, before each")
    Upvote.create_based_on_rule(@actor, @event)
  end

  describe ".find_qualified_for" do
    it "finds an award that's under user's point total" do
      wrong_reward = Reward.create({title: "A mug", point_minimum: 250})
      right_reward = Reward.create({title: "A snake!", point_minimum: 150})

      r = Reward.find_qualified_for(@author)
      expect(r).to eql(right_reward)
    end

    it "finds an award that closest to user's point total" do
      wrong_reward1 = Reward.create({title: "A mug", point_minimum: 150})
      wrong_reward2 = Reward.create({title: "A cup", point_minimum: 152})
      right_reward = Reward.create({title: "A snake!", point_minimum: 154})

      r = Reward.find_qualified_for(@author)
      expect(r).to eql(right_reward)
    end
  end
end
