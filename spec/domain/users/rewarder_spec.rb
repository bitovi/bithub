require 'domain/spec_helper'

describe Users::Rewarder do

  describe "#reward_if_eligible" do
    it "should create one achievement for each award that the user is eligible for" do
      author = create(:user, name: "Nikica")
      Upvote.create_based_on_rule(create(:user, name: "Veljko"), create(:entity_determined, scoring_rule: create(:scoring_rule, upvote_value: 155), author: author))
      r1 = Reward.create({title: "A mug.", point_minimum: 50})
      r2 = Reward.create({title: "A snake!", point_minimum: 100})
      r3 = Reward.create({title: "An aligatro!!", point_minimum: 155})

      author.reward_if_eligible
      author.rewards.should =~ [r1, r2, r3]
    end

    it "should create an achievement only for rewards that are not already achievement/present" do
      author = create(:user, name: "Nikica")
      Upvote.create_based_on_rule(create(:user, name: "Veljko"), create(:entity_determined, scoring_rule: create(:scoring_rule, upvote_value: 155), author: author))
      r1 = Reward.create({title: "A mug.", point_minimum: 50})
      author.reward_if_eligible

      r2 = Reward.create({title: "A snake!", point_minimum: 100})
      r3 = Reward.create({title: "An aligatro!!", point_minimum: 155})

      author.reward_if_eligible
      author.rewards.should =~ [r1, r2, r3]
    end

    it "doesn't create duplicate achievements" do
      author = create(:user, name: "Nikica")
      Upvote.create_based_on_rule(create(:user, name: "Veljko"), create(:entity_determined, scoring_rule: create(:scoring_rule, upvote_value: 155), author: author))
      r = Reward.create({title: "A mug.", point_minimum: 50})

      author.reward_if_eligible
      author.reward_if_eligible
      expect(author.rewards).to eql [r]
    end
  end

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
