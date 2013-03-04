require 'spec_helper'

describe Rule do
  describe "#best_match" do

    context "when given no tags" do
      it "matches the default rule" do
        default_rule = Rule.default_rule
        expect(Rule.best_match).to eq(default_rule)
      end
    end

    context "when given tags" do
      let (:a_rule) { build(:rule, :required_tags => ['a_tag', 'another_tag']) }

      it "tries to get the exact match" do
        expect(Rule.best_match(['a_tag', 'another_tag'])).to eq(a_rule)
      end

      it "tries to get a partial match" do
        expect(Rule.best_match(['a_tag', 'not_another_tag'])).to eq(a_rule)
      end
    end
  end
end
