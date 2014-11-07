module Services
  class FilterBuilder

    def initialize(service)
      @service = service
    end

    def build_constraints
    end

    def feed_name_constraint
      @service.filter.natlang_queries << NatlangQuery.new({
        is_negated: false,
        attr: 'feed_name',
        op: 'is',
        val: @service.feed_name 
      })
    end

    def service_type_constraint
    end
  end
end
