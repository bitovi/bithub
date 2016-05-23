module NatlangQueries
  class Applier
    def initialize(filter, ar_klass)
      @filter = filter
      @ar_klass = ar_klass
    end

    def scope(select_values = nil)
      skope = @ar_klass

      if select_values
        skope = skope.select(select_values)
      end

      @filter.combined_queries.each do |q|
        skope = method_scope(q, skope)
      end

      skope
    end

    def method_scope(q, skope = Bit)
      skope.send(q[:method], q[:arg])
    end
  end
end
