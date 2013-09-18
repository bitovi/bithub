require 'spec_helper'

describe Award do

  describe ".create_with_strategy" do
    it "should award the user with the appropriate number of points" do
      rule = create(:rule, upvote_value: 7)
      author = create(:user, name: "Nikica")
      admin = create(:user, name: "Admin")

      event = create(:github_issue, rule: rule, title: "This is wrong.")
      event_to_award = create(:github_push, author: author, parent: event, title: "Solved!")

      old_score = author.score
      Upvote.create_based_on_rule(admin, event)
      Award.create_with_strategy(admin, event_to_award, {strategy: :double_parents_upvotes})
      new_score = author.reload.score

      expect(new_score).to eq(old_score+(event.reload.upvotes.sum(:value)*2))
    end
  end

  describe ".double_upvote_value" do
    it "returns double the upvote value of the event as the value for a new award" do
      user = create(:user)
      rule = create(:rule, upvote_value: 3)
      event = create(:github_push, rule: rule)
      Upvote.create_based_on_rule(user, event)

      expect(Award.double_upvote_value(event)).to eq(event.upvotes.sum(:value)*2)
    end
  end
  
  describe ".double_parents_upvote_value" do
    it "returns double the upvote value of the event as the value for a new award" do
      user = create(:user)
      rule = create(:rule, upvote_value: 7)
      pe = create(:github_issue, rule: rule)
      ce = create(:github_push, parent: pe)
      Upvote.create_based_on_rule(user, pe)

      expect(Award.double_parents_upvote_value(ce)).to eq(ce.parent.upvotes.sum(:value)*2)
    end
  end

  describe ".total_value" do
    it "returns an award value specified in the rule" do
      award_value = 100
      rule = create(:rule, award_value: award_value)
      event = create(:event_determined, rule: rule, title: "Event in award_spec, testing_total_value.")
      expect(Award.total_value(event)).to eq(award_value)
    end
  end

end
