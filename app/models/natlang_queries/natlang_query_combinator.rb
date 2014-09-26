class NatlangQueryCombinator

  def initialize(qs, are_conj)
    @qs = qs
    @are_conj = are_conj
  end

  def combine
    @qs.map do |q|
      q.to_ar_query
    end
  end

end
