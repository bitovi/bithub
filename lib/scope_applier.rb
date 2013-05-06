class ScopeApplier
  def self.apply_muster_query_to_scope(scope, muster_query)
    scope = scope.joins(muster_query[:joins]) if !muster_query[:joins].blank?
    scope = scope.includes(muster_query[:includes]) if !muster_query[:includes].blank?
    scope = scope.offset(muster_query[:offset]) if !muster_query[:offset].blank?
    scope = scope.limit(muster_query[:limit]) if muster_query[:count].blank?
    scope
  end
  
  def self.apply_tag_based_params_to_scope(logic_analyzer, scope, params)
    taggables = logic_analyzer.pluck_and_process_tag_based_params(params)
    if taggables
      scope = scope.tagged_with(taggables[:any], :any => true) if taggables[:any]
      scope = scope.tagged_with(taggables[:all]) if taggables[:all]
    end
    scope
  end
  
  def self.apply_regular_params_to_scope(logic_analyzer, scope, params)
    regpars = logic_analyzer.pluck_and_process_regular_params(params)
    scope = scope.where(regpars) if regpars
    scope
  end
end
