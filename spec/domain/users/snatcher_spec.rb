require 'domain/spec_helper'

describe Users::Snatcher do

  before(:all) do
    @veljko = create(:user, name: 'Veljko')
    @nikica = create(:user, name: 'Nikica')
  end

  describe "#snatch_entities" do
    it "transfers entities" do
      e1 = create(:github_issue, author: v)
      e2 = create(:twitter_follow, author: v)
      e3 = create(:twitter_tweet, author: v)

      n.reload.snatch_entities_from(v)
      v.reload.entities.should =~ []
      n.reload.entities.should =~ [e1, e2, e3]
    end
  end

  describe "#snatch_actions" do
    it "transfers upvotes/awards/internals/anteups in which the user is an actor" do
      issue = create(:github_issue, author: v)
      issue_comment = create(:github_issue_comment, parent: issue, author: v)

      upvote = create(:upvote, applies_to: issue, actor: n)
      award = create(:award, applies_to: issue_comment, actor: n)

      v.reload.snatch_actions_from(n)
      v.reload.actions.should =~ [upvote, award] 
      n.reload.actions.should =~ []
    end
  end

  describe "#snatch_internals" do
    it "transfers internals" do
      i = Internal.create!({receiver: n, value: 1, comment: "Completed profile."})

      v.reload.snatch_internals_from(n)
      v.reload.internals.should =~ [i]
      n.reload.internals.should =~ []      
    end
  end
end
