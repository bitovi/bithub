require 'domain/spec_helper'

describe Determinators::ScoringRuleDeterminator do

  let (:default_rule) { FactoryGirl.build(:scoring_rule)}
  let (:rule1) { FactoryGirl.build(:scoring_rule, required_tags: %w(a_tag another_tag)) }
  let (:rule2) { FactoryGirl.build(:scoring_rule, required_tags: %w(a_tag another_tag not_another_tag)) }
  let (:rule3) { FactoryGirl.build(:scoring_rule, required_tags: %w(a_tag another_tag not_another_tag the_fourth_one)) }
  
  let(:rules) {[ default_rule, rule1, rule2, rule3 ]}

  describe "#best_match" do

    context "when given no tags" do
      it "responds with the default rule" do
        d = Determinators::ScoringRuleDeterminator.new(nil, rules)
        expect(d.best_match).to eq(default_rule)
      end
    end

    context "when given tags" do
      context "and there is an exact match" do
        it "finds the exact match" do
          d = Determinators::ScoringRuleDeterminator.new(%w(a_tag another_tag), [default_rule, rule2])
          expect(d.best_match).to eq(rule2)
        end
      
        it "chooses the rule with the exact match over the rule with a non-exact match" do
          d = Determinators::ScoringRuleDeterminator.new(%w(a_tag another_tag), [default_rule, rule2, rule3])
          expect(d.best_match).to eq(rule2)
        end

      end

      context "there is no exact match" do
        it "tries to get a partial match" do
          d = Determinators::ScoringRuleDeterminator.new(%w(a_tag another_tag quazi bazi ha), rules)
          expect(d.best_match).to eq(rule1)
        end
      
        it "chooses a better matching rule (with higher nmb of matches)" do
          d = Determinators::ScoringRuleDeterminator.new(%w(a_tag another_tag not_another_tag the_fourth_one), [rule2, rule3])
          expect(d.best_match).to eq(rule3)
        end
      end
    end

  end

end
