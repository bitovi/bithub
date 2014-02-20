# require 'domain/entities/spec_helper'

# describe Entities::Bithub::Post do

#   def build_post(attrs={})
#     payload = double()
#     payload.stub(:id => attrs[:id] || nil)
#     payload.stub(:feed => "bithub")
#     payload.stub(:type => "post")
#     payload.stub(:title => attrs[:title] || "Posting some content from bithub ...")
#     payload.stub(:url => attrs[:url] || "http://bithub.com/foobar")
#     payload.stub(:body => attrs[:body] || "Lorem ipsum ...")
#     payload.stub(:image => "")
#     payload.stub(:category => attrs[:category] || "article")
#     payload.stub(:project => attrs[:project] || "canjs")
#     payload.stub(:location => attrs[:location] || nil)
#     payload.stub(:scheduled_for => attrs[:scheduled_for] || nil)
#     payload.stub(:origin_author_id => attrs[:origin_author_id] || nil)
#     payload.stub(:origin_author_name => attrs[:origin_author_name] || nil)
#     payload.stub(:origin_author_feed => attrs[:origin_author_feed] || nil)
#     payload.stub(:local_author_id => attrs[:local_author_id] || nil)
#     payload.stub(:origin_ts => attrs[:origin_ts] || Time.now)
#     Entities::Bithub::Post.new(payload).procure
#   end

#   describe "#build" do
#     it "instances new Entity object" do
#       msg = build_post
#       msg.determine.normalize.persist!

#       expect(msg.instance.title).not_to be_empty
#       # expect(msg.instance.url).not_to be_empty
#       # expect(msg.instance.props['origin_author_name']).not_to be_empty
#       expect(msg.instance.tag_list).to match_array ['canjs', 'bithub', 'article', 'post']
#     end
#   end

# end

# # describe "#new_from_bithub" do
# #   before :all do
# #     @comment_category_determination_rule = create(:category_determination_rule, name: "comment", scorings: {comment: 1})
# #   end
# #   after :all do
# #     @comment_category_determination_rule.destroy
# #   end

# #   let(:args) { original_args }
# #   let(:ev) { Event.new_from_bithub(args) }

# #   it "determines tags" do
# #     expect(ev.tag_list).to be_instance_of(ActsAsTaggableOn::TagList)
# #   end

# #   it "determines a feed" do
# #     expect(ev.feed).to be_instance_of(Tag)
# #   end

# #   it "determines a category" do
# #     expect(ev.category).to be_instance_of(Tag)
# #   end

# #   it "assigns the body" do
# #     expect(ev.body).to be_instance_of(String)
# #   end

# #   it "assigns the title" do
# #     expect(ev.title).to be_instance_of(String)
# #   end

# #   it "calculates the hash key" do
# #     expect(ev.hash.class).to be
# #   end

# #   it "sets the origin and thread timestamps" do
# #     expect(ev.origin_ts).to be
# #     expect(ev.origin_date).to be
# #     expect(ev.thread_updated_at).to be
# #     expect(ev.thread_updated_date).to be
# #   end

# # end

# # describe "#update_from_bithub" do

# #   before(:each) do
# #     @ev = Event.new_from_bithub(original_args)
# #     @ev.update_from_bithub(updated_args)
# #   end

# #   it "re-determines the feed" do
# #     expect(@ev.feed).to eq(Tag.find_by_name(updated_args[:feed]))
# #   end

# #   it "re-determines the category" do
# #     expect(@ev.category).to eq(Tag.find_by_name(updated_args[:category]))
# #   end

# #   it "re-determines tags" do
# #     @ev.tag_list.should =~ only_tags(updated_args)
# #   end
# # end

# # def original_args
# #   ActiveSupport::HashWithIndifferentAccess.new({
# #     title: 'A new entity arrives!',
# #     body: 'Whasaaap?',
# #     category: 'comment',
# #     feed: 'github',
# #     tags: ['issue_comment', 'canjs']
# #   })
# # end

# # def updated_args
# #   ActiveSupport::HashWithIndifferentAccess.new({
# #     title: 'Changed title',
# #     body: 'Changed body',
# #     category: 'code',
# #     feed: 'twitter',
# #     tags: ['push_event', 'jquerypp']
# #   })
# # end
