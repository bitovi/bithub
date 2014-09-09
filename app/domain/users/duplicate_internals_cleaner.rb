module Users
  class DuplicateInternalsCleaner

    def initialize(user)
      @user = user
    end

    def duplicates
      @user.internals.order("id asc").all.to_a\
        - @user.internals.order("id asc").all.to_a.uniq {|i| i.variant}
    end

    def clean
      is = duplicates.andand.map {|i| i.destroy }
      @user.update_total_score
      not(is.empty?)
    end

  end
end
