module Entities
  module Persistable

    def persist
      @instance.parent.save if @instance.parent
      @instance.children.each {|c| c.save} if @instance.children
      if @instance.save
        Notifier.notify_client(:entity_persisted, { entity: @instance })
      end

      self
    end

    def persist!
      @instance.parent.save! if @instance.parent
      @instance.children.each {|c| c.save!} if @instance.children
      @instance.save!
      Notifier.notify_client(:entity_persisted, { entity: @instance })
      self
    end
  end
end
