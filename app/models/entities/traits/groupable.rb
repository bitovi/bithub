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
      
      Celluloid.logger.debug "[DISPATCHER][GROUPING] finding_parents completed in #{finding_parents_time}"
      Celluloid.logger.debug "[DISPATCHER][GROUPING] finding_children completed in #{finding_children_time}"
      Celluloid.logger.debug "[DISPATCHER][GROUPING] writing_history completed in #{writing_history_time}"
      Celluloid.logger.debug "[DISPATCHER][GROUPING] bumping_thread completed in #{bumping_thread_time}"

      self
    end

    def adopt
      find_children_time = Benchmark.measure do
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
      end

      if self.respond_to? :build_children
        @instance.children += build_children
      end

      update_from_children_time = Benchmark.measure do
        if not(@instance.children.blank?) && @instance.latest_child_ts && (@instance.latest_child_ts > @payload.origin_ts)
          update_from_children if self.respond_to? :update_from_children
        end
      end
      
      Celluloid.logger.debug "[DISPATCHER][GROUPING] find_children_time completed in #{find_children_time}"
      Celluloid.logger.debug "[DISPATCHER][GROUPING] update_from_children_time completed in #{update_from_children_time}"

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
