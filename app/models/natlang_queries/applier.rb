module NatlangQueries
  class Applier
    def initialize(filter, ar_klass)
      @filter = filter
      @ar_klass = ar_klass
    end

    def scope
      skope = @ar_klass

      @filter.combined_queries.each do |q|
        skope = method_scope(q, skope)
      end

      skope
    end

    def method_scope(q, skope = Entity)
      skope.send(q[:method], q[:arg])
    end
  end
end
