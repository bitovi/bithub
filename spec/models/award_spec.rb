require 'spec_helper'

describe Award do
  describe ".double_upvote_value" do
    it "returns double the upvote value of the event as the value for a new award" do
      rule = create(:rule, upvote_value: 3)
      a1 = create(:user, name: "Nikica")
      a2 = create(:user, name: "Veljko")
      event = create(:event_determined, rule: rule)
      Upvote.create_based_on_rule(a1, event)
      Upvote.create_based_on_rule(a2, event)

      expect(Award.double_upvote_value(event)).to eq(event.upvotes.sum(:value)*2)
    end
  end

  describe ".total_value" do
    it "returns an award value specified in the rule" do
      award_value = 100
      rule = create(:rule, award_value: award_value)
      event = create(:event_determined, rule: rule)
      expect(Award.total_value(event)).to eq(award_value)
    end
  end
end
