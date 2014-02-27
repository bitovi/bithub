require 'domain/spec_helper'

describe Determinators::CategoryDeterminator do

  let (:rule1) { FactoryGirl.build(:category_determination_rule, name: "foo", scorings: {"foo" => 1}) }
  let (:rule2) { FactoryGirl.build(:category_determination_rule, name: "foobarbaz", scorings: {"foo" => 1, "bar" =>1, "baz" =>1}) }
  let (:rule3) { FactoryGirl.build(:category_determination_rule, name: "foobar", scorings: {"foo" => 1, "bar" => 1}) }

  let(:rules) {[ rule1, rule2, rule3 ]}

  describe "#category_scores" do
    it "returns hash with rule/category names and calculated scores" do
      d = Determinators::CategoryDeterminator.new(['foo', 'bar', 'baz'], rules)

      result = [
        {:name => "foo", :score => 1},
        {:name => "foobarbaz", :score => 3},
        {:name => "foobar", :score => 2}
      ]

      expect(d.category_scores).to eq(result)
    end
  end

  describe "#best_match" do

    it "matches rule with highest score and returns it's name" do
      d = Determinators::CategoryDeterminator.new(%w(foo bar baz), rules)
      expect(d.best_match).to eq(rule2.name)
    end

    it "returns nil if there is no match with score higher than 0" do
      d = Determinators::CategoryDeterminator.new(%w(more tags), rules)
      expect(d.best_match).to eq nil
    end

    it "returns first match if more rules achieve the same score" do
      d = Determinators::CategoryDeterminator.new(%w(foo bar), rules)
      expect(d.best_match).to eq rule2.name
    end

  end

end
