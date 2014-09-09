require 'domain/spec_helper'

RSpec.describe Tagger::Rule, :type => :tagger do

  let(:rule) { Tagger::Rule.new({required_tags: {"foo" => 5, "bar" => 10}}) }
  let(:tag_foo) { Tagger::Tag.new({name: "foo"}) }
  let(:tag_bar) { Tagger::Tag.new({name: "bar"}) }
  let(:tag_baz) { Tagger::Tag.new({name: "baz"}) }

  describe "#rate" do
    it "rates given array of tags" do
      expect(rule.rate([tag_foo])).to eq(5)
      expect(rule.rate([tag_bar])).to eq(10)
      expect(rule.rate([tag_foo, tag_bar])).to eq(15)
      expect(rule.rate([tag_foo, tag_bar, tag_baz])).to eq(15)
    end
  end

end
