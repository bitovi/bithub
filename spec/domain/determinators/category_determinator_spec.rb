require 'domain/spec_helper'

describe Determinators::CategoryDeterminator do

  let (:rule1) do
    FactoryGirl.build(:category_determination_rule, name: "foo", required_tags: {"foo" => 1}, category_name: "foo")
  end

  let (:rule2) do
    FactoryGirl.build(:category_determination_rule, name: "foobarbaz", required_tags: {"foo" => 1, "bar" =>1, "baz" =>1}, category_name: "foobarbaz")
  end

  let (:rule3) do FactoryGirl.build(:category_determination_rule, name: "foobar", required_tags: {"foo" => 1, "bar" => 1}, name: "foobar")
  end

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

    it "returns first match if more rules achieve the same score" do
      d = Determinators::CategoryDeterminator.new(%w(foo bar), rules)
      expect(d.best_match).to eq rule2.name
    end

  end

end
