require 'spec_helper'

describe Rule do
  describe "#best_match" do

    context "when given no tags" do
      it "matches the default rule" do
        default_rule = create(:rule)
        expect(Rule.best_match).to eq(default_rule)
      end
    end

    context "when given tags" do
      context "and there is an exact match" do
        it "finds the exact match" do
          rule_of_two = create(:rule, :required_tags => ['a_tag', 'another_tag']) 
          expect(Rule.best_match(['a_tag', 'another_tag'])).to eq(rule_of_two)
        end
      
        it "chooses the rule with the exact match over the rule with a non-exact match" do
          rule_of_two = create(:rule, :required_tags => ['a_tag', 'another_tag']) 
          rule_of_three = create(:rule, :required_tags => ['a_tag', 'another_tag', 'not_another_tag'])
          expect(Rule.best_match(['a_tag', 'another_tag'])).to eq(rule_of_two)
        end

      end

      context "there is no exact match" do
        it "tries to get a partial match" do
          rule_of_two = create(:rule, :required_tags => ['a_tag', 'another_tag']) 
          expect(Rule.best_match(['a_tag', 'another_tag', 'not_another_tag', 'the_fourth_one'])).to eq(rule_of_two)
        end
      
        it "chooses a better matching rule (with higher nmb of matches" do
          rule_of_two = create(:rule, :required_tags => ['a_tag', 'another_tag']) 
          rule_of_three = create(:rule, :required_tags => ['a_tag', 'another_tag', 'not_another_tag'])
          expect(Rule.best_match(['a_tag', 'another_tag', 'not_another_tag', 'the_fourth_one'])).to eq(rule_of_three)
        end
      end
    end
  end
end
