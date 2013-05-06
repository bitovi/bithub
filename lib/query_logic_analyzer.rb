class QueryLogicAnalizer
  TAG_FIELD_NAMES = ['tag', 'feed', 'category']
  DELIMITERS = { :and => ',', :or => '|', :between => ':' }

  def initialize(model)
    @model = model
  end

  def apply_muster_query_to_scope(scope, muster_query)
    scope = scope.joins(muster_query[:joins]) if !muster_query[:joins].blank?
    scope = scope.includes(muster_query[:includes]) if !muster_query[:includes].blank?
    scope = scope.offset(muster_query[:offset]) if !muster_query[:offset].blank?
    scope = scope.limit(muster_query[:limit]) if muster_query[:count].blank?
    scope
  end


  # =========> Tag based params

  def apply_tag_based_params_to_scope(scope, params)
    taggables = pluck_and_process_tag_based_params(params)
    if taggables
      scope = scope.tagged_with(taggables[:any], :any => true) if taggables[:any]
      scope = scope.tagged_with(taggables[:all]) if taggables[:all]
    end
    scope
  end

  def pluck_and_process_tag_based_params(params)
    Hash[params.select{|qi| tag_based_query_item?(qi)}.map{|el| process_query_logic_for_tag_based_items(qi)}]
  end

  def process_query_logic_for_tag_based_items(query_item)
    case
    when or_query?(query_item)
      [:any, extract_alternatives(qi)]
    when and_query?(query_item)
      [:all, extract_conditions(query_item) ]
    else equals_query?(query_item)
      [:all, Array.wrap(val)]
    end
  end

  # =========> Regular params

  def apply_regular_params_to_scope!(scope, params)
    regpars = pluck_and_process_regular_params(params)
    scope = scope.where(regpars) if regpars
    scope
  end

  def pluck_and_process_regular_params(params)
    Hash[params.select{|qi| regular_and_valid_query_item?(qi)}.map{|qi| process_query_logic(qi)}]
  end

  def regular_and_valid_query_item?(query_item)
    qi_name, * = query_item
    @model.has_an_attribute?(qi_name) && !taggable_query_item?(qi_name)
  end

  def process_query_logic(query_item)
    qi_name, qi_value = query_item
    case
    when between_query?(query_item)
      [qi_name, extract_range(query_item)]
    when or_query?(query_item)
      [qi_name, extract_alternatives(query_item)]
    else equals_query?(query_item)
      [qi_name, qi_value]
    end
  end

  # =========> Extracting methods

  def extract_range(query_item)
    qi_name, qi_value = query_item
    lower_str, higher_str = qi_value.split(DELIMITERS[:between])
    type = @model.columns_hash[qi_name].type
    case
    when type == :datetime || type == :date
      lower = (!lower_str || lower_str.blank?) ?  Date.new(0) + 1.year : DateTime.parse(lower_str)
      higher = (!higher_str || higher_str.blank?) ? DateTime.tomorrow : DateTime.parse(higher_str)
    when type == :integer
      lower = (lower_str && !lower_str.blank?) ? lower_str.to_i : -(2**(0.size * 8 -2)) # Platform MIN_INT
      higher = higher_str ? higher_str.to_i : (2**(0.size * 8 -2) -1) # Platform MAX_INT
    else
      klass = Object.const_get(type.capitalize)
      lower = klass.new(lower_str)
      higher = klass.new(higher_str)
    end
    lower..higher
  end

  def extract_alternatives(query_item)
    *, qi_value = query_item
    qi_value.split(DELIMITERS[:or])
  end

  def extract_conjuctions(query_item)
    *, qi_value = query_item
    qi_value.is_a?(Array) ? qi_value : qi_value.split(DELIMITERS[:and])
  end


  # =========> Checking methods

  def tag_based?(query_item)
    qi_name, * = query_item 
    TAG_FIELD_NAMES.include?(qi_name)
  end

  def between_query?(query_item)
    *, qi_value = query_item
    qi_value.include?(DELIMITERS[:between])
  end

  def or_query?(query_item)
    *, qi_value = query_item
    qi_value.include?(DELIMITERS[:or])
  end

  def and_query?(query_item)
    *, qi_value = query_item
    qi_value.include?(DELIMITERS[:and]) || qi_value.is_a?(Array)
  end

  def equals_query?(query_item)
    true
  end
end
