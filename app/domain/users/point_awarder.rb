module Users
  class PointAwarder

    CompletedProfileComment = "Completed profile."


    attr_reader :user

    def initialize(user)
      @user = user
    end

    def execute
      @user.save
    end

    def award_points_for_completing_profile
      @user.internals.build({
        receiver: @user,
        variant: :completed_profile,
        comment: CompletedProfileComment,
        value: 1,
      }) if completed_profile?
      self
    end

    def award_points_for_linking(provider)
      @user.internals.build({
        receiver: @user,
        variant: "linked_#{provider.downcase}".to_sym,
        comment: "Logged in with #{provider.capitalize}.",
        value: 1,
      })
      self
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
