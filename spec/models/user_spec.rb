require 'spec_helper'

describe User do

  context "upon creation" do
    before :each do
      #
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

        activity_upvote = Activity.create_upvote(admin, event)
        activity_upvote = Activity.create_upvote(admin, event_reply)
        activity_stake = Activity.create_stake(admin, event, 25)
        activity_award = Activity.create_award(admin, event_reply)
        activity_stake_other = Activity.create_stake(author_reply, event_other, 20)        

        sum = event_reply.rule.authorship_value
            + event_reply.activities.upvotes.sum('value')
            + event_reply.activities.awards.sum('value')
            - author_reply.activities.fullfilled_stakes.sum('value')

        expect(author_reply.sum_points).to eq(sum)
      end
    end
    
  end

end
