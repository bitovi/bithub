module Entities
  module Persistable

    def persist
      @instance.parent.save if @instance.parent
      @instance.children.each {|c| c.save} if @instance.children
      @instance.save
      @instance.bump_thread
    end

    def persist!
      @instance.parent.save! if @instance.parent
      @instance.children.each {|c| c.save!} if @instance.children
      @instance.save!
      @instance.bump_thread
    end
  end
end
