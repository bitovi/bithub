module Entities
  module Groupable

    def group
      finding_parents_time = Benchmark.measure do
        join_family
      end

      finding_children_time = Benchmark.measure do
        adopt
      end

      writing_history_time = Benchmark.measure do
        write_history
      end

      bumping_thread_time = Benchmark.measure do
        bump_thread
      end

      self
    end

    def adopt
      find_children_time = Benchmark.measure do
        if self.respond_to? :find_children
          if (c = find_children)
            if c.is_a?(Array)
              @instance.children += c
            elsif c.is_a?(ActiveRecord::Relation)
              @instance.children += c.where(true)
            else
              @instance.children += [c]
            end
          end
        end
      end

      if self.respond_to? :build_children
        @instance.children += build_children
      end

      update_from_children_time = Benchmark.measure do
        if not(@instance.children.blank?) && @instance.latest_child_ts && (@instance.latest_child_ts > @payload.origin_ts)
          update_from_children if self.respond_to? :update_from_children
        end
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
