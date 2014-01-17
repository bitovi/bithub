require 'domain/entities/spec_helper'

describe Entities::Forum::Post do

  def build_post(attrs={})
    payload = double()
    payload.stub(:feed => "forum")
    payload.stub(:type => "post")
    payload.stub(:title => attrs[:title] || "Forum post title")
    payload.stub(:body => attrs[:body] || "Something with canjs ...")
    payload.stub(:link => attrs[:link] || "http://forums.com/some-post-slug")
    payload.stub(:subforum => attrs[:subforum] || "questions")
    payload.stub(:origin_author_name => attrs[:origin_author_name] || "random user")
    payload.stub(:origin_ts => attrs[:origin_ts] || Time.now)
    Entities::Forum::Post.new(Entity, payload).procure
  end
  
  question = {title: "Question", link: "http://forums.com/question", origin_ts: 2.hours.ago}
  answer = {title: "Answer", link: "http://forums.com/question#100"}
  answer2 = {title: "Answer2", link: "http://forums.com/question#200"}
  unrelated = {title: "Unrelated", link: "http://forums.com/unrelated"}

  describe "#build" do
    it "instances new Entity object" do
      post = build_post
      Entities::Determinator.new(post).determine
      post.persist!
      
      expect(post.instance.title).to be_a(String)
      expect(post.instance.body).to be_a(String)
      expect(post.instance.url).to be_a(String)
      expect(post.instance.props['origin_author_name']).to be_a(String)
      expect(post.instance.tag_list).to match_array ['canjs', 'post', 'forum', 'question']
    end
  end

  describe "#procure_*" do
    it "checks for parents and children" do
      a1 = build_post(answer); Entities::Determinator.new(a1).determine; a1.persist!
      q = build_post(question); Entities::Determinator.new(q).determine; q.persist!
      a2 = build_post(answer2); Entities::Determinator.new(a2).determine; a2.persist!
      u = build_post(unrelated); Entities::Determinator.new(u).determine; u.persist!

      expect(q.procure_children.length).to eq(2)
      expect(a1.procure_parent.id).to eq(q.instance.id)
      expect(a2.procure_parent.id).to eq(q.instance.id)
      expect(u.procure_parent).to be_nil
      expect(u.procure_children.length).to eq(0)
    end
  end
end
