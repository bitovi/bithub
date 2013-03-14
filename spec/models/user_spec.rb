require 'spec_helper'

describe User do

  context "upon creation / first sign in" do
    describe "#get_all_events" do
    end
  end

  describe "#sum_points" do
    it "calculates total points" do
      rule = create(:rule, authorship_value: 100, award_value: 1000)
      rule_reply = create(:rule, authorship_value: 10)

      author = create(:user, name: "Author")
      author_reply = create(:user, name: "Reply author")
      admin = create(:user, name: "Admin")

      event = create(:event_determined, rule: rule, author: author)
      event_reply = create(:event_determined, rule: rule_reply, author: author_reply, parent: event)
      event_other = create(:event_determined)

      upvote = Upvote.create_upvote(admin, event)
      upvote_reply = Upvote.create_upvote(admin, event_reply)
      anteup = Anteup.create_anteup(admin, event, 25)
      award = Award.create_award(admin, event_reply)
      anteup_other = Anteup.create_anteup(author_reply, event_other, 20)        

      sum = event_reply.rule.authorship_value
      + event_reply.upvotes.sum('value')
      + event_reply.awards.sum('value')
      - author_reply.anteups.fullfilled.sum('value')

      expect(author_reply.sum_points).to eq(sum)
    end
  end

  describe ".top" do
    it "returns list of top n users sorted by score" do
      user1 = create(:user); user1.stub(:sum_points) {1}
      user2 = create(:user); user2.stub(:sum_points) {2}
      user3 = create(:user); user3.stub(:sum_points) {3}
      user4 = create(:user); user4.stub(:sum_points) {4}
      user5 = create(:user); user5.stub(:sum_points) {5}
      user6 = create(:user); user6.stub(:sum_points) {6}
      
      top_users = User.top(3)      
      #expect(top_users).to eq([user6, user5, user4])
    end
  end

end
