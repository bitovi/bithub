require 'spec_helper'

describe User do
  describe "#score" do
    before :all do
      @rule = create(:rule, authorship_value: 33, award_value: 0, upvote_value: 11)
      @author = create(:user, name: "Nikica")
      @actor = create(:user, name: "Veljko")
    end

    after :all do
      @rule.destroy
      @author.destroy
      @actor.destroy
    end

    it "calculates total authorship points" do
      event = create(:event_determined, rule: @rule, author: @author)
      expect(@author.authored_events_total).to eq(33)
    end

    it "calculates total upvote points" do
      event = create(:event_determined, rule: @rule, author: @author)
      Upvote.create_based_on_rule(@actor, event)
      expect(@author.upvotes_total).to eq(11)
    end

    it "calculates total award points" do
      event = create(:event_determined, rule: @rule, author: @author)
      Upvote.create_based_on_rule(@actor, event)
      Award.create_with_strategy(@actor, event, {strategy: :double_the_upvotes})
      expect(@author.awards_total).to eq(11*2)
    end

    it "calculates total points" do
      event = create(:event_determined, rule: @rule, author: @author)
      Upvote.create_based_on_rule(@actor, event)
      Award.create_with_strategy(@actor, event, {strategy: :double_the_upvotes})
      expect(@author.score).to eq(11+11*2+33)
    end
  end

  describe ".select_with_score" do
    it "calculates score for each user by using built in PG fns" do
      user = create(:user)
      u = User.where(id: user.id).select_with_score.first
      expect(u.total_score).to be_a(Integer)
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

  describe "#reward_if_eligible" do
    it "creates an achievement for the user if he has enough points" do
      author = create(:user, name: "Nikica")
      Upvote.create_based_on_rule(create(:user, name: "Veljko"), create(:event_determined, rule: create(:rule, upvote_value: 155), author: author))
      reward = Reward.create({title: "A snake!", point_minimum: 154})

      author.reward_if_eligible
      author.rewards.should =~ [reward]
    end
  end

  describe "#collect_authored_events" do
    it "collects all events with matching props -> origin_author_id" do
      user = build(:user, name: 'Floppy', email: 'floppy@qua.wat')
      user.identities << build(:identity, uid: 123456789, provider: 'twitter')
      user.identities << build(:identity, uid: 987654321, provider: 'github')
      user.save!

      e1 = create(:event_determined, title: "First event", props: { origin_author_id: 123456789 })
      e2 = create(:event_determined, title: "Second event", props: { origin_author_id: 987654321 })
      e3 = create(:event_determined, title: "Third event", props: { origin_author_id: 123456789 })

      events = [e1, e2, e3]
      user.collect_authored_events
      user.events.should =~ events
    end
  end
end
