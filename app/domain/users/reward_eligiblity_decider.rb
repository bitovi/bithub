module Users
  class RewardEligiblityDecider
    attr_reader :user, :reward

    def initialize(kwargs)
      @user = kwargs[:user] if kwargs[:user].present?
      @reward = kwargs[:reward] if kwargs[:reward].present?
    end
 
    def reward_if_eligible
      if earned_rewards.present?
        @user.rewards << reject_achieved(earned_rewards)
      end
    end
    
    def unreward_if_uneligible
      @user.achievements.each do |a|
        a.destroy if a.reward.point_minimum > score
      end
    end
    
    def reward_all_eligible_users
      if eligible_users.present?
        @reward.rewardees << reject_achievers(eligible_users)
      end
    end

    def earned_rewards
      Reward.where("point_minimum <= ?", score).all
    end
    
    def eligible_users
      Users.where("total_score >= ?", point_minimum).all
    end
    
    def execute
      (@user.present? && @user.save) || (@reward.present? && @reward.save)
    end

    private

    def reject_achieved(rewards)
      rewards.reject { |r| @user.rewards.include? r  }
    end

    def reject_achievers(users)
      users.reject { |r| @reward.rewardees.include? u  }
    end

    def point_minimum
      @reward.point_minimum
    end

    def score
      @cached_score ? @user.total_score : @user.score
    end
  end
end
