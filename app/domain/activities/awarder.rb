module Activities
  class Awarder
    PossibleStrategies = [:double_upvote_value, :double_parents_upvote_value, :rule_based_value]

    def initialize(actor, applies_to)
      @actor = actor
      @applies_to = applies_to
    end

    def award(opts)
      if (valid?(provided_strategy(opts)) && (@award = Award.create(actor: actor, applies_to: applies_to, value: self.send(@strategy))))
        async_exec_post_award_actions
        @award
      end
    end
    
    def unaward
      @actor.awards_as_actor.where(applies_to: applies_to).first
      if @award.destroy
        async_exec_post_unaward_actions
      end
    end

    def async_exec_post_award_actions
      @applies_to.author.async_update_total_score if self.applies_to.author
      @applies_to.author.async_reward_if_eligible if self.applies_to.author
    end

    def async_exec_post_unaward_actions
      @applies_to.author.async_update_total_score if self.applies_to.author
      @applies_to.author.async_unreward_if_uneligible if self.applies_to.author
    end

    # Strategies
    
    def valid?(strategy)
      if PossibleStrategies.reduce(false) {|s| acc || (s == strategy)}
        strategy
      else
        nil
      end
    end
    
    def provided_strategy(opts)
      @strategy = (s = opts[:strategy]) ? s : :double_upvote_value
    end

    def double_upvote_value
      @applies_to.upvotes.sum(:value) * 2
    end

    def double_parents_upvote_value(event)
      @applies_to.top_level_parent.upvotes.sum(:value) * 2 if @applies_to.parent
    end

    def rule_based_value
      if p = @applies_to.parent
        [p.scoring_rule.award_value, p.upvotes.sum('value')].reduce(&:+)
      else
        [@applies_to.scoring_rule.award_value, @applies_to.upvotes.sum('value')].reduce(&:+)
      end
    end
  end
end

