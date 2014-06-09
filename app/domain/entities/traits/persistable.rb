module Entities
  module Persistable

    def persist
      @instance.parent.save if @instance.parent
      @instance.children.each {|c| c.save} if @instance.children
      @instance.save
    end

    def persist!
      @instance.parent.save! if @instance.parent
      @instance.children.each {|c| c.save!} if @instance.children
      @instance.save!
    end
  end
end
