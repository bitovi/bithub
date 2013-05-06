class QueryLogicAnalyzer
  TAG_FIELD_NAMES = ['tag', 'feed', 'category']
  DELIMITERS = { :and => ',', :or => '|', :between => ':' }

  def initialize(model)
    @model = model
  end

  # =========> Tag based params

  def pluck_and_process_tag_based_params(params)
    process_tag_based_params(pluck_tag_based_params(params))
  end

  def pluck_tag_based_params(params)
    params.select{|k,v| qi=[k,v]; tag_based_query_item?(qi)}
  end

  def process_tag_based_params(params)
    hash = Hash.new
    params.each do |qi|
      merge_with_existing_keys(hash, process_query_logic_for_tag_based_items(qi))
    end
    hash
  end

  def tag_based_query_item?(query_item)
    qi_name, * = query_item 
    TAG_FIELD_NAMES.include?(qi_name.to_s)
  end

  def process_query_logic_for_tag_based_items(query_item)
    *, qi_value = query_item 
    case
    when or_query?(query_item)
      [:any, extract_alternatives(query_item)]
    when and_query?(query_item)
      [:all, extract_conjuctions(query_item)]
    else equals_query?(query_item)
      [:all, Array.wrap(qi_value)]
    end
  end

  # =========> Regular params

  def pluck_and_process_regular_params(params)
    process_regular_params(pluck_regular_params(params))
  end

  def pluck_regular_params(params)
    params.select{|k,v| qi=[k,v]; regular_and_valid_query_item?(qi)}
  end

  def process_regular_params(params)
    Hash[params.map{|qi| process_query_logic_for_regular_query_items(qi)}]
  end

  def regular_and_valid_query_item?(query_item)
    qi_name, * = query_item
    @model.has_an_attribute?(qi_name) and !tag_based_query_item?(query_item)
  end

  def process_query_logic_for_regular_query_items(query_item)
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
    column_type = @model.columns_hash[qi_name.to_s].type
    case
    when column_type == :datetime || column_type  == :date
      lower = (!lower_str || lower_str.blank?) ?  Date.new(0) + 1.year : DateTime.parse(lower_str)
      higher = (!higher_str || higher_str.blank?) ? DateTime.tomorrow : DateTime.parse(higher_str)
    when column_type == :integer
      lower = (lower_str && !lower_str.blank?) ? lower_str.to_i : -(2**(0.size * 8 -2)) # Platform MIN_INT
      higher = higher_str ? higher_str.to_i : (2**(0.size * 8 -2) -1) # Platform MAX_INT
    else
      klass = Object.const_get(column_type.capitalize)
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

  # ========> Helper methods

  def merge_with_existing_keys(hash, qi)
    qi_key, qi_val = qi
    if hash[qi_key]
      hash[qi_key] += qi_val
    else
      hash[qi_key] = qi_val
    end
    hash
  end
end
