module Activities
  class Upvoter

    def initialize(actor, applies_to)
      @actor = actor
      @applies_to = applies_to
    end

    def upvote
      if (@upvote = Upvote.create(actor: @actor, applies_to: @applies_to, value: upvote_value))
        #@upvote.applies_to.update_total_upvotes
        #@upvote.applies_to.author.update_total_score if @upvote.applies_to.author
        async_exec_post_upvote_actions
        @upvote
      end
    end

    def unupvote
      @upvote = @actor.upvotes.where(applies_to: @applies_to).first
      if @upvote.destroy
        async_exec_post_unvote_actions
      end
    end

    def async_exec_post_upvote_actions
      update_entity_and_author
      @upvote.applies_to.author.async_reward_if_eligible if @upvote.applies_to.author
    end

    def asnyc_exec_post_unupvote_actions
      update_entity_and_author
      @upvote.applies_to.author.async_unreward_if_uneligible if @upvote.applies_to.author
    end

    def update_entity_and_author
      @upvote.applies_to.async_update_total_upvotes
      @upvote.applies_to.author.async_update_total_score if @upvote.applies_to.author
    end

    private
    def upvote_value
      @applies_to.scoring_rule.upvote_value
    end

  end
end
