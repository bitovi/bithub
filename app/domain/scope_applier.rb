class ScopeApplier

  DEFAULT_LIMIT = 50

  def initialize(initial, query)
    @scope = initial
    @query = query
    apply_overrides
  end

  def apply_muster_query_to_scope(muster_query, skip_limits: false)
    @scope = @scope.joins(muster_query[:joins]) if !muster_query[:joins].blank?
    @scope = @scope.includes(muster_query[:includes]) if !muster_query[:includes].blank?

    unless skip_limits
      @scope = @scope.offset(muster_query[:offset]) if !muster_query[:offset].blank?
      @scope = @scope.limit(muster_query[:limit] || DEFAULT_LIMIT) if muster_query[:count].blank?
    end
    self
  end

  def apply_existence_attrs_to_scope
    if (existence_attrs = @query.pluck_and_process_existence_attributes)
      existence_attrs.each do |na_name|
        @scope = @scope.where("#{@query.table_name}.#{na_name} IS NOT NULL")
      end
    end

    if (nonexistence_attrs = @query.pluck_and_process_nonexistence_attributes)
      nonexistence_attrs.each do |na_name|
        @scope = @scope.where("#{@query.table_name}.#{na_name} IS NULL")
      end
    end
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
      regpars.each do |k,v|
        @scope = @scope.where(regpars)
      end
    end
    self
  end

  def apply_order_to_scope
    if (orderings = @query.pluck_and_process_orderings)
      @scope = @scope.order(orderings) if @params && not(@params[:funnel_id] || @params[:funnel_name])
    end
    self
  end

  def apply_overrides
    thread_updated_ts = @query.qi('thread_updated_date')
    unless thread_updated_ts.nil?
      @scope = override_thread_updated_date(thread_updated_ts.value)
    end
  end

  def orderings
    @query.pluck_and_process_orderings || ""
  end

  def result
    @scope
  end

  private

  def override_thread_updated_date(val)
    start_date, end_date = val.split(':')

    if end_date.nil?
      end_date = start_date
    end

    start_date = Date.parse(start_date)
    end_date   = Date.parse(end_date)

    end_date = end_date + 1.day - 1.second

    args = [@query.clientTz, start_date, end_date]
    @scope.where("thread_updated_ts AT TIME ZONE 'UTC' AT TIME ZONE ? BETWEEN ? AND ?", *args)
  end
end
