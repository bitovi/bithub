require_relative 'support/spec_helper'

describe Reward do
  before :each do
    @author = create(:user, name: "Nikica")
    @actor = create(:user, name: "Veljko")
    @rule = create(:scoring_rule, upvote_value: 155)
    @entity = create(:entity_determined, scoring_rule: @rule, author: @author, title: "Entity in reward_spec, before each")
    Upvote.create_based_on_rule(@actor, @entity)
  end

  describe ".find_all_qualified_for" do
    it "finds all award that are under user's point total" do
      r1 = Reward.create({title: "A mug", point_minimum: 50})
      r2 = Reward.create({title: "A snake!", point_minimum: 120})
      r3 = Reward.create({title: "The edge", point_minimum: 155})

      rs = Reward.find_all_qualified_for(@author)
      rs.should =~ [r1, r2, r3]
    end

    it "doesn't find awards that are more valuable than user's total points" do
      r1 = Reward.create({title: "A cup", point_minimum: 180})
      r2 = Reward.create({title: "A snake!", point_minimum: 200})

      rs = Reward.find_all_qualified_for(@author)
      expect(rs).to eql []
    end
  end
end
