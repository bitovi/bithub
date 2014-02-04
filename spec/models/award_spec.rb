require_relative 'support/spec_helper'

describe Award do

  describe ".create_based_on_strategy" do
    it "should award the user with the appropriate number of points" do
      rule = create(:rule, upvote_value: 7)
      author = create(:user, name: "Nikica")
      actor = create(:user, name: "Veljko")
      admin = create(:user, name: "Admin")

      event = create(:github_issue, rule: rule, title: "This is wrong.", author: actor)
      event_to_award = create(:github_push, author: author, parent: event, title: "Solved!")

      old_score = author.score
      Upvote.create_based_on_rule(admin, event)
      Award.create_based_on_strategy(admin, event_to_award, {strategy: :double_parents_upvotes})
      new_score = author.reload.score

      expect(new_score).to eq(old_score+(event.reload.upvotes.sum(:value)*2))
    end
  end

  describe ".double_upvote_value" do
    it "returns double the upvote value of the event as the value for a new award" do
      user = create(:user)
      rule = create(:rule, upvote_value: 3)
      event = create(:github_push, rule: rule, author: user)
      Upvote.create_based_on_rule(user, event)

      expect(Award.double_upvote_value(event)).to eq(event.upvotes.sum(:value)*2)
    end
  end
  
  describe ".double_parents_upvote_value" do
    it "returns double the upvote value of the event as the value for a new award" do
      user = create(:user)
      rule = create(:rule, upvote_value: 7)
      pe = create(:github_issue, rule: rule, author: user)
      ce = create(:github_push, parent: pe)
      Upvote.create_based_on_rule(user, pe)

      expect(Award.double_parents_upvote_value(ce)).to eq(ce.parent.upvotes.sum(:value)*2)
    end

    it "should look at the top level parent to know the amount it needs to award" do
      user = create(:user)
      rule = create(:rule, upvote_value: 7)
      ie = create(:github_issue, rule: rule)
      pe = create(:github_push, parent: ie)
      cce = create(:github_commit_comment, parent: pe, author: user)

      Upvote.create_based_on_rule(user, cce)
      expect(Award.double_parents_upvote_value(cce)).to eq(cce.top_level_parent.upvotes.sum(:value)*2)
    end
  end

  describe ".rule_based_value" do
    it "returns an award value specified in the rule" do
      award_value = 100
      rule = create(:rule, award_value: award_value)
      event = create(:event_determined, rule: rule, title: "Event in award_spec, testing_potential_value.")
      expect(Award.rule_based_value(event)).to eq(award_value)
    end
  end

end
