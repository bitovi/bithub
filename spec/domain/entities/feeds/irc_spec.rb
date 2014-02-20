# require 'domain/entities/spec_helper'

# describe Entities::Irc::Message do

#   def build_post(attrs={})
#     payload = double()
#     payload.stub(:feed => "irc")
#     payload.stub(:type => "message")
#     payload.stub(:title => attrs[:title] || "Yet another message on #canjs ...")
#     payload.stub(:url => attrs[:url] || "http://foobar.com/webchat")
#     payload.stub(:origin_author_name => attrs[:origin_author_name] || "nickname")
#     payload.stub(:origin_ts => attrs[:origin_ts] || Time.now)
#     Entities::Irc::Message.new(payload).procure
#   end
  
#   describe "#build" do
#     it "instances new Entity object" do
#       msg = build_post
#       msg.determine.normalize.persist!
      
#       expect(msg.instance.title).not_to be_empty
#       expect(msg.instance.url).not_to be_empty
#       expect(msg.instance.props['origin_author_name']).not_to be_empty
#       expect(msg.instance.tag_list).to match_array ['canjs', 'irc', 'chat', 'message']
#     end
#   end

# end
