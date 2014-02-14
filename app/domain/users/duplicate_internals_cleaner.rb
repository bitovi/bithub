module Users
  class DuplicateInternalsCleaner

    def initialize(user)
      @user = user
    end

    def duplicates
      @user.internals - @user.internals.uniq_by {|i| i.comment}
    end

    def execute
      duplicates.andand.each { |i| i.destroy }
      @user.update_total_score
    end

  end
end
