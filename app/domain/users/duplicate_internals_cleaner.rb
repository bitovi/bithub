module Users
  class DuplicateInternalsCleaner

    def initialize(user)
      @user = user
    end

    def duplicates
      @user.internals - @user.internals.uniq_by {|i| i.comment}
    end

    def clean
      is = duplicates.andand.map {|i| i.destroy }
      @user.update_total_score
      not(is.empty?)
    end

  end
end
