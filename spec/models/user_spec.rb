require 'spec_helper'

describe User do
  describe "#score" do
    it "calculates points for authorships" do
      author = create(:user)
      rule = create(:rule, authorship_value: 11, award_value: 0, upvote_value: 0)
      event = create(:event_determined, rule: rule, author: author)
      expect(author.score).to eq(11)
      expect(author.authored_events_total).to eq(11)
    end

    it "calculates points for upvotes" do
      author = create(:user)
      rule = create(:rule, authorship_value: 0, award_value: 0, upvote_value: 1)
      event = create(:event_determined, rule: rule, author: author)
      Upvote.create_upvote(author, event)
      expect(author.score).to eq(1)
      expect(author.upvotes_total).to eq(1)
    end

    it "calculates points for awards" do
      author = create(:user); solver = create(:user)
      rule = create(:rule, authorship_value: 0, award_value: 22, upvote_value: 0)
      event = create(:event_determined, rule: rule, author: author)
      event_reply = create(:event_determined, rule: rule, parent: event, author: solver)
      Award.create_award(author, event_reply)
      expect(solver.score).to eq(22)
      expect(solver.awards_total).to eq(22)
    end
    
    it "calculates points for awards+upvotes" do
      author = create(:user); solver = create(:user)
      rule = create(:rule, authorship_value: 0, award_value: 22, upvote_value: 7)
      event = create(:event_determined, rule: rule, author: author)
      event_reply = create(:event_determined, rule: rule, parent: event, author: solver)
      Upvote.create_upvote(solver, event)
      Award.create_award(author, event_reply)
      expect(solver.awards_total).to eq(29) # Award value only = 29 (22+7)
      expect(author.score).to eq(7)
    end

    it "calculates points for anteups" do
      author = create(:user); solver = create(:user)
      rule = create(:rule, authorship_value: 0, award_value: 0, upvote_value: 0)
      event = create(:event_determined, rule: rule, author: author)
      event_reply = create(:event_determined, rule: rule, parent: event, author: solver)
      Anteup.create_anteup(author, event, 33)
      Award.create_award(author, event_reply)
      expect(solver.score).to eq(33)
      expect(author.fulfilled_anteups_total).to eq(33)
    end

    it "calculates total points" do
      admin = create(:user); author = create(:user); solver = create(:user)
      rule = create(:rule, authorship_value: 100, award_value: 1000, upvote_value: 1)
      rule_reply = create(:rule, authorship_value: 10, upvote_value: 1)
      event = create(:event_determined, rule: rule, author: author)
      event_reply = create(:event_determined, rule: rule_reply, author: solver, parent: event)

      Upvote.create_upvote(admin, event)
      Upvote.create_upvote(admin, event_reply)
      Anteup.create_anteup(author, event, 25)
      Award.create_award(admin, event_reply)
      expect(author.score).to eq(100+1-25)
      expect(solver.score).to eq(10+1+26+1000)
    end
  end

  describe "#update_blank_oauth_attrs" do
    it "updates the user's attrs if they're blank" do
      user = create(:user, name: "Nikica Jokic", email: nil)
      user.update_blank_oauth_attrs!({name: "Nikica Prdovic", email: "neektza@gmail.com"})
      expect(user.reload.email).to eq ("neektza@gmail.com")
    end
  end

  describe "#merge_identities!" do
    let(:user) { create(:user, name: 'Nikica', email: 'neektza@gmail.com') }
    let(:another_user) { create(:user, name: 'Veljko', email: 'veljko@kset.org') }

    context "when there is already a github identity associated with the user" do
      it "adds a new twitter identity to the existing user" do
        identity_twitter = create(:identity, uid: 123456789, provider: 'twitter')
        identity_github = create(:identity, uid: 987654321, provider: 'github', user: user)

        user.merge_identities!(identity_twitter)
        expect(user.reload.identities.where({:provider => 'twitter'}).first).to be
      end
    end

    context "when there is already a twitter identity associated with the user" do
      it "adds a new twitter identity to the existing user" do
        identity_github = create(:identity, uid: 987654321, provider: 'github')
        identity_twitter = create(:identity, uid: 123456789, provider: 'twitter', user: user)

        user.merge_identities!(identity_github)
        expect(user.reload.identities.where({:provider => 'github'}).first).to be
      end
    end

    context "when there is already another user that owns the identity being merged" do
      it "destroys the other user and snatches it's identity" do
        old_user_id = another_user.id
        identity_github = create(:identity, uid: 987654321, provider: 'github', user: user)
        identity_twitter = create(:identity, uid: 123456789, provider: 'twitter', user: another_user)
        user.merge_identities!(identity_twitter)
        expect(User.where(:id => old_user_id).first).to be_nil
      end
    end
  end

  describe "#collect_authored_events" do
    it "collects all events with matching props -> origin_author_id"
  end
end
