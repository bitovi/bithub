require 'domain/entities/spec_helper'

describe Entities::Bithub::Post do

  # describe "#new_from_bithub" do
  #   before :all do
  #     @comment_category_determination_rule = create(:category_determination_rule, name: "comment", scorings: {comment: 1})
  #   end
  #   after :all do
  #     @comment_category_determination_rule.destroy
  #   end

  #   let(:args) { original_args }
  #   let(:ev) { Event.new_from_bithub(args) }

  #   it "determines tags" do
  #     expect(ev.tag_list).to be_instance_of(ActsAsTaggableOn::TagList)
  #   end

  #   it "determines a feed" do
  #     expect(ev.feed).to be_instance_of(Tag)
  #   end

  #   it "determines a category" do
  #     expect(ev.category).to be_instance_of(Tag)
  #   end

  #   it "assigns the body" do
  #     expect(ev.body).to be_instance_of(String)
  #   end

  #   it "assigns the title" do
  #     expect(ev.title).to be_instance_of(String)
  #   end

  #   it "calculates the hash key" do
  #     expect(ev.hash.class).to be
  #   end

  #   it "sets the origin and thread timestamps" do
  #     expect(ev.origin_ts).to be
  #     expect(ev.origin_date).to be
  #     expect(ev.thread_updated_at).to be
  #     expect(ev.thread_updated_date).to be
  #   end

  # end

  # describe "#update_from_bithub" do

  #   before(:each) do
  #     @ev = Event.new_from_bithub(original_args)
  #     @ev.update_from_bithub(updated_args)        
  #   end

  #   it "re-determines the feed" do
  #     expect(@ev.feed).to eq(Tag.find_by_name(updated_args[:feed]))
  #   end

  #   it "re-determines the category" do
  #     expect(@ev.category).to eq(Tag.find_by_name(updated_args[:category]))
  #   end

  #   it "re-determines tags" do
  #     @ev.tag_list.should =~ only_tags(updated_args)
  #   end
  # end
end
