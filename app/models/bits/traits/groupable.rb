module Bits
  module Groupable

    def group
      write_history
      join_family
      adopt
      bump_thread
      self
    end

    def write_history
      @instance.events << @event.instance if @event.instance
    end

    def adopt
      if self.respond_to? :find_children
        if (c = find_children)
          if c.is_a?(Array)
            @instance.children += c
          elsif c.is_a?(ActiveRecord::Relation)
            @instance.children += c.to_a
          else
            @instance.children += [c]
          end
        end
      end

      if self.respond_to? :build_children
        @instance.children += build_children
      end

      if !@instance.children.blank? && @instance.latest_child_ts && (@instance.latest_child_ts > @event.origin_ts)
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

    def bump_thread
      @instance.bump_thread
    end

  end
end
