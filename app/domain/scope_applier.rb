class ScopeApplier

  def initialize(initial, query)
    @scope = (initial.class.name =~ /Relation/) ? initial : initial.scoped
    @query = query
  end

  def apply_muster_query_to_scope(muster_query)
    @scope = @scope.joins(muster_query[:joins]) if !muster_query[:joins].blank?
    @scope = @scope.includes(muster_query[:includes]) if !muster_query[:includes].blank?
    @scope = @scope.offset(muster_query[:offset]) if !muster_query[:offset].blank?
    @scope = @scope.limit(muster_query[:limit]) if muster_query[:count].blank?
    self
  end

  def apply_negated_attrs_to_scope
    if (negated_attrs = @query.pluck_and_process_negated_attributes)
      negated_attrs.each do |na_name, na_value|
        @scope = @scope.where("#{@query.table_name}.#{na_name} <> ?", na_value)
      end
    end
    self
  end
  
  def apply_tag_based_params_to_scope
    if (taggables = @query.pluck_and_process_tag_based_params)
      @scope = @scope.tagged_with(taggables[:any], :any => true) if taggables[:any]
      @scope = @scope.tagged_with(taggables[:all]) if taggables[:all]
    end
    self
  end
  
  def apply_regular_params_to_scope
    if (regpars = @query.pluck_and_process_regular_params)
      @scope = @scope.where(regpars)
    end
    self
  end
  
  def apply_order_to_scope
    if (orderings = @query.pluck_and_process_orderings)
      orderings.each do |attribute, direction|
        @scope = @scope.order("#{attribute} #{direction}")
      end
    end
    self
  end

  private
  def replace_attr_if_virt(pair, virtual_attr_pairs)
    attribute, direction = pair.split
    if virtual_attr_pairs[attribute]
      [virtual_attr_pairs[attribute], direction]
    else
      [attribute, direction]
    end
  end
end
