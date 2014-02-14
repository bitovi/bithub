module Users
  class PointAwarder

    COMPLETED_PROFILE_COMMENT = "Completed profile."

    attr_reader :user

    def initialize(user)
      @user = user
    end

    def execute
      @user.save
    end

    def award_points_for_completing_profile
      if completed_profile? && not(already_awarded_for_profile_completion?)
        Internal.create({
          receiver: @user,
          value: 1,
          comment: COMPLETED_PROFILE_COMMENT
        })
      end
      self
    end

    def award_points_for_linking(provider)
      @user.internals.build({receiver: @user, value: 1, comment: "Logged in with #{provider.capitalize}."})
      self
    end

    def already_awarded_for_profile_completion?
      Internal.where(receiver_id: @user.id, comment: COMPLETED_PROFILE_COMMENT).present?
    end

    def completed_profile?
      @user.name.present? &&
      @user.email.present? &&
      @user.address.present? &&
      @user.city.present? &&
      @user.postal.present? &&
      @user.country.present?
    end

  end
end
