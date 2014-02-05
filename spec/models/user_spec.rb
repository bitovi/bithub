require_relative 'support/spec_helper'

Delayed::Worker.delay_jobs = false

describe User do
  describe "#score" do
    before :all do
      @rule = create(:scoring_rule, authorship_value: 33, award_value: 0, upvote_value: 11)
      @author = create(:user, name: "Nikica")
      @actor = create(:user, name: "Veljko")
    end

    after :all do
      @rule.destroy
      @author.destroy
      @actor.destroy
    end

    it "should calculate total authorship points" do
      event = create(:entity_determined, scoring_rule: @rule, author: @author, title: "Event in user_spec, testing #score from authorship")
      expect(@author.reload.authored_entities_total).to eq(33)
    end

    it "should calculate total upvote points" do
      event = create(:entity_determined, scoring_rule: @rule, author: @author, title: "Event in user_spec, testing #score from upvotes")
      Upvote.create_based_on_rule(@actor, event)
      expect(@author.upvotes_total).to eq(11)
    end

    it "should calculate total award points" do
      event = create(:entity_determined, scoring_rule: @rule, author: @author, title: "Event in user_spec, testing #score from awards")
      Upvote.create_based_on_rule(@actor, event)
      Award.create_based_on_strategy(@actor, event, strategy: :double_the_upvotes)
      expect(@author.awards_total).to eq(11*2)
    end

    it "should calculate total points" do
      event = create(:entity_determined, scoring_rule: @rule, author: @author, title: "Event in user_spec, testing total #score")
      Upvote.create_based_on_rule(@actor, event)
      Award.create_based_on_strategy(@actor, event, strategy: :double_the_upvotes)
      expect(@author.reload.score).to eq(11+11*2+33)
    end
  end

  describe "#update_blank_oauth_attrs" do
    it "should update the user's attrs if they're blank" do
      user = create(:user, name: "Nikica Jokic", email: nil)
      user.update_blank_oauth_attrs!({name: "Nikica Prdovic", email: "neektza@gmail.com"})
      expect(user.reload.email).to eq ("neektza@gmail.com")
    end
  end

  describe "#link_ident!" do

    before :each do
      @nikica = create(:user, name: 'Nikica', email: 'neektza@gmail.com')
      @veljko = create(:user, name: 'Veljko', email: 'veljko@kset.org')
    end

    context "when there is already a github identity associated with the user" do
      it "should add a new twitter identity to the existing user" do
        identity_github = create(:identity, uid: 987654321, provider: 'github', user: @nikica)
        identity_twitter = create(:identity, uid: 123456789, provider: 'twitter')

        @nikica.link_ident!(identity_twitter)
        expect(@nikica.reload.identities.where({:provider => 'twitter'}).first).to be
      end
    end

    context "when there is already a twitter identity associated with the user" do
      it "shoul add a new twitter identity to the existing user" do
        identity_twitter = create(:identity, uid: 123456789, provider: 'twitter', user: @nikica)
        identity_github = create(:identity, uid: 987654321, provider: 'github')

        @nikica.link_ident!(identity_github)
        expect(@nikica.reload.identities.where({:provider => 'github'}).first).to be
      end
    end

    context "when there is already another user that owns the identity being merged" do
      it "should destroy the other user and snatches it's identity" do
        identity_github = create(:identity, uid: 987654321, provider: 'github', user: @nikica)
        identity_twitter = create(:identity, uid: 123456789, provider: 'twitter', user: @veljko)
        @nikica.link_ident!(identity_twitter)
        expect(User.where(:id => @veljko).first).to be_nil
      end
    end
  end

  describe "#snatch_entities_from" do
    it "transfers entities" do
      v = create(:user, name: 'Veljko')
      n = create(:user, name: 'Nikica')

      e1 = create(:github_issue, author: v)
      e2 = create(:twitter_follow, author: v)
      e3 = create(:twitter_tweet, author: v)

      n.reload.snatch_entities_from(v)
      v.reload.entities.should =~ []
      n.reload.entities.should =~ [e1, e2, e3]
    end
  end

  describe "#snatch_actions_from" do
    it "transfers upvotes/awards/internals/anteups in which the user is an actor" do
      v = create(:user, name: 'Veljko')
      n = create(:user, name: 'Nikica')

      issue = create(:github_issue, author: v)
      issue_comment = create(:github_issue_comment, parent: issue, author: v)

      upvote = create(:upvote, applies_to: issue, actor: n)
      award = create(:award, applies_to: issue_comment, actor: n)

      v.reload.snatch_actions_from(n)
      v.reload.actions.should =~ [upvote, award] 
      n.reload.actions.should =~ []
    end
  end

  describe "#snatch_internals_from" do
    it "transfers internals" do
      v = create(:user, name: 'Veljko')
      n = create(:user, name: 'Nikica')

      i = Internal.create!({receiver: n, value: 1, comment: "Completed profile."})

      v.reload.snatch_internals_from(n)
      v.reload.internals.should =~ [i]
      n.reload.internals.should =~ []      
    end
  end
  
  describe "#reward_if_eligible" do
    it "should create one achievement for each award that the user is eligible for" do
      author = create(:user, name: "Nikica")
      Upvote.create_based_on_rule(create(:user, name: "Veljko"), create(:entity_determined, scoring_rule: create(:scoring_rule, upvote_value: 155), author: author))
      r1 = Reward.create({title: "A mug.", point_minimum: 50})
      r2 = Reward.create({title: "A snake!", point_minimum: 100})
      r3 = Reward.create({title: "An aligatro!!", point_minimum: 155})

      author.reward_if_eligible
      author.rewards.should =~ [r1, r2, r3]
    end

    it "should create an achievement only for rewards that are not already achievement/present" do
      author = create(:user, name: "Nikica")
      Upvote.create_based_on_rule(create(:user, name: "Veljko"), create(:entity_determined, scoring_rule: create(:scoring_rule, upvote_value: 155), author: author))
      r1 = Reward.create({title: "A mug.", point_minimum: 50})
      author.reward_if_eligible
      
      r2 = Reward.create({title: "A snake!", point_minimum: 100})
      r3 = Reward.create({title: "An aligatro!!", point_minimum: 155})

      author.reward_if_eligible
      author.rewards.should =~ [r1, r2, r3]
    end

    it "doesn't create duplicate achievements" do
      author = create(:user, name: "Nikica")
      Upvote.create_based_on_rule(create(:user, name: "Veljko"), create(:entity_determined, scoring_rule: create(:scoring_rule, upvote_value: 155), author: author))
      r = Reward.create({title: "A mug.", point_minimum: 50})
      
      author.reward_if_eligible
      author.reward_if_eligible
      expect(author.rewards).to eql [r]
    end
  end

  describe "#completed_profile?" do
    it "should return false if user's profile has not been completed" do
      user = build(:user, name: "Mali")
      expect(user.completed_profile?).to eq false
    end
    
    it "should return true if user's profile has been completed" do
      user = build(:user,
        name: "Mali",
        email: "mali@mail.com",
        address: "Ajme",
        city: "Moram",
        postal: "Pisat",
        country: Country.new(name: "Ove gluposti")
      )

      expect(user.completed_profile?).to eq true
    end
  end

  describe "#already_awarded_for_profile_completion" do
    it "should return true if the user has already been awarded" do
      @user = create(:user)
      expect(@user.already_awarded_for_profile_completion?).to eql false
    end
    
    it "should return false if the user hasn't already been awarded" do
      @user = create(:user)
      Internal.create!({receiver: @user, value: 1, comment: "Completed profile."})
      expect(@user.already_awarded_for_profile_completion?).to eql true
    end
  end

  describe "#check_and_award_points_for_completing_profile" do
    it "should award +1 point for competing profile" do
      @user = create(:user)
      @user.stub(:completed_profile?).and_return(true)
      @user.check_and_award_points_for_completing_profile
      expect(@user.score).to eq 1
    end
  end
  
  describe "#award_points_for_linking" do
    it "should award +1 point for singning in with twitter/github for the first time" do
      @user = create(:user)
      @user.award_points_for_linking('twitter').save!
      expect(@user.reload.score).to eq 1
    end
  end

  describe "#collect_authored_entities" do
    it "collects all entities with matching props -> origin_author_id" do
      user = build(:user, name: 'Floppy', email: 'floppy@qua.wat')
      user.identities << build(:identity, uid: 123456789, provider: 'twitter')
      user.identities << build(:identity, uid: 987654321, provider: 'github')
      user.save!

      e1 = create(:entity_determined, title: "First event", props: { origin_author_id: 123456789 })
      e2 = create(:entity_determined, title: "Second event", props: { origin_author_id: 987654321 })
      e3 = create(:entity_determined, title: "Third event", props: { origin_author_id: 123456789 })

      entities = [e1, e2, e3]
      user.collect_authored_entities
      user.reload.entities.should =~ entities
    end
  end
end
