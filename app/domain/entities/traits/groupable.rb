module Entities
  module Groupable

    def group
      join_family
      adopt
      write_history
      bump_thread
      self
    end

    def adopt
      if self.respond_to? :find_children
        if (c = find_children)
          @instance.children += if c.is_a?(Array)
                                  c
                                elsif c.is_a?(ActiveRecord::Relation)
                                  c.where(true)
                                else
                                  [c]
                                end
        end
      end

      if self.respond_to? :build_children
        @instance.children += build_children
      end

      if not(@instance.children.blank?) && (@instance.latest_child_ts > @payload.origin_ts)
        update_from_children if self.respond_to? :update_from_children
      end

      self
    end

    def join_family
      if self.respond_to? :find_parent
        if (p = self.find_parent)
          @instance.parent = p
        end
      end

      if self.respond_to? :build_parent
        @instance.parent = build_parent
      end

      if @instance.parent
        update_parent if self.respond_to? :update_parent
      end

      self
    end

    def write_history
      @instance.events << @event.instance if @event.instance
    end

    def bump_thread
      @instance.bump_thread
    end

  end
end
