require 'spec_helper'

describe Tag do
  describe ".find_or_create" do
    context "when there is no tag in the system" do
      it "creates the tag and returns it" do
        new_or_found_tag = Tag.find_or_create("some_tag")
        found_tag = Tag.where({:name => "some_tag"}).first
        expect(found_tag).to eql(new_or_found_tag)
      end
    end

    context "when the tag is already in the system" do
      it "just returns the tag"
    end
  end
end
