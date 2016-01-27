module Entities
  module Persistable

    def persist
      @instance.parent.save if @instance.parent
      @instance.children.each {|c| c.save} if @instance.children
      @instance.save
      self
    end

    def persist!
      @instance.parent.save! if @instance.parent
      @instance.children.each {|c| c.save!} if @instance.children
      @instance.save!
      self
    end
  end
end
