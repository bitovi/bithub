require 'spec_helper'

describe Tag do
  describe ".find_or_create" do
    context "when there is no tag in the system" do
      it "creates the tag and returns it" do
        a_tag = Tag.new({:name => "some_tag"})
        expect(Tag.find_or_create_by_name({:name => "some_tag"})).to eql(a_tag)
      end
    end

    context "when the tag is already in the system" do
      it "just returns the tag"
    end
  end
end
