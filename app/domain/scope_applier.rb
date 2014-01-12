class ScopeApplier

  def initialize(query_logic_analyzer)
    @logic_analyzer = query_logic_analyzer
  end

  def apply_muster_query_to_scope(scope, muster_query)
    scope = scope.joins(muster_query[:joins]) if !muster_query[:joins].blank?
    scope = scope.includes(muster_query[:includes]) if !muster_query[:includes].blank?
    scope = scope.offset(muster_query[:offset]) if !muster_query[:offset].blank?
    scope = scope.limit(muster_query[:limit]) if muster_query[:count].blank?
    scope
  end

  def apply_negated_attrs_to_scope(scope, params)
    negated_attrs = @logic_analyzer.pluck_and_process_negated_attributes(params)
    negated_attrs.each do |na_name, na_value|
      scope = scope.where("#{@logic_analyzer.table_name}.#{na_name} <> ?", na_value)
    end if negated_attrs
    scope
  end
  
  def apply_tag_based_params_to_scope(scope, params)
    taggables = @logic_analyzer.pluck_and_process_tag_based_params(params)
    if taggables
      scope = scope.tagged_with(taggables[:any], :any => true) if taggables[:any]
      scope = scope.tagged_with(taggables[:all]) if taggables[:all]
    end
    scope
  end
  
  def apply_regular_params_to_scope(scope, params)
    regpars = @logic_analyzer.pluck_and_process_regular_params(params)
    scope = scope.where(regpars) if regpars
    scope
  end
  
  def apply_order_to_scope(scope, params, categories_order = nil)
    virtual_attr_pairs = {
      'upvotes' => 'total_upvotes',
      'score' => 'total_score',
      'categories' => "idx(array#{categories_order}, category_id)"
    }

    if !params[:order].blank?
      params[:order] = [params[:order]] unless params[:order].kind_of?(Array)
      params[:order].map{|el| el.gsub(':', ' ')}.each do |str_pair|
        attribute, direction = replace_attr_if_virt(str_pair, virtual_attr_pairs)
        scope = scope.order("#{attribute} #{direction}")
      end
    end
    scope
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
