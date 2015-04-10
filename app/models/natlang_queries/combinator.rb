module NatlangQueries
  class Combinator
    def initialize(qs)
      @qs = qs
    end

    def combine
      @qs.map do |q|
        q.to_ar_query
      end
    end
  end
end
