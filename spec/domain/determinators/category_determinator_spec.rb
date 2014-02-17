require 'domain/spec_helper'

describe Determinators::CategoryDeterminator do
  
  context "upon determination" do

    before(:all) { 
      @rule1 = build(:category_determination_rule, name: "foo", scorings: {"foo" => 1})
      @rule2 = build(:category_determination_rule, name: "foobarbaz", scorings: {"foo" => 1, "bar" =>1, "baz" =>1})
      @rule3 = build(:category_determination_rule, name: "foobar", scorings: {"foo" => 1, "bar" => 1})
    }

    describe "#calculate_scores" do
      it "returns hash with rule/category names and calculated scores" do
        rules = [@rule1, @rule2, @rule3]
        tags = ['foo', 'bar', 'baz']
        result = [{:name => "foo", :score => 1},
                  {:name => "foobarbaz", :score => 3},
                  {:name => "foobar", :score => 2}]
        expect(CategoryDeterminationRule.calculate_scores(tags, rules)).to eq(result)
      end
    end

    describe "#best_match" do

      it "matches rule with highest score and returns it's name" do
        rules =  [@rule1, @rule2, @rule3]
        tags = ["foo","bar","baz"]
        expect(CategoryDeterminationRule.best_match(tags, rules)).to eq(@rule2.name)
      end

      it "returns nil if there is no match with score higher than 0" do
        expect(CategoryDeterminationRule.best_match(["more","tags"], [@rule2])).to eq(nil)
      end

      it "returns first match if more rules achieve the same score" do
        rules =  [@rule1, @rule2, @rule3]
        tags = ["foo","bar"]
        expect(CategoryDeterminationRule.best_match(tags, rules)).to eq(@rule2.name)
      end

    end

  end
end
