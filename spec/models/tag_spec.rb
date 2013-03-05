require 'spec_helper'

describe Tag do
  describe ".find_or_create" do
    it "creates or finds the tag and returns it" do
      new_or_found_tag = Tag.find_or_create("some_tag")
      found_tag = Tag.where({:name => "some_tag"}).first
      expect(new_or_found_tag).to eql(found_tag)
    end
  end
end
