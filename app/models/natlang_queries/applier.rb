module NatlangQueries
  class Applier
    def initialize(filter, ar_klass)
      @filter = filter
      @ar_klass = ar_klass
    end

    def scope
      skope = @ar_klass
      if @filter.all?
        @filter.combined_queries.each do |q|
          skope = method_scope(q, skope)
        end
      elsif @filter.any?
        scopes = @filter.combined_queries.map do |q|
          method_scope(q)
        end
        skope = Entity.union_scope *scopes
      end
      skope
    end

    def method_scope(q, skope = Entity)
      if q[:method] == :tagged_with
        tagged_with_scope(q, skope)
      else
        skope.send(q[:method], q[:arg])
      end
    end

    def tagged_with_scope(q, skope)
      if q[:arg][1]
        skope.tagged_with(q[:arg][0], q[:arg][1])
      else
        skope.tagged_with(q[:arg][0])
      end
    end
  end
end
