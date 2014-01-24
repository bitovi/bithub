module Entities
  module Persistable

    def set_feed_and_type
      @instance.feed_name = feed_name.snake_case
      @instance.type_name = type_name.snake_case
    end

    def persist
      set_feed_and_type
      @instance.parent.save if @instance.parent
      @instance.children.each {|c| c.save} if @instance.children
      @instance.save
    end

    def persist!
      set_feed_and_type
      @instance.parent.save! if @instance.parent
      @instance.children.each {|c| c.save!} if @instance.children
      @instance.save!
    end
  end
end
