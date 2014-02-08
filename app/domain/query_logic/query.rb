require_relative 'query_item'

module QueryLogic
  class Query
    VIRT_ATTRS = {
      'upvotes' => 'total_upvotes',
      'score' => 'total_score',
      'feed' => 'feed_name',
      'type' => 'type_name',
      'category' => 'category_name',
      'categories' => "idx(array#{Tag.categories_order}, category_id)",
    }

    def initialize(model, params)
      @qis = params.map {|kv| QueryItem.new(model, kv)}
      @raw = params
    end

    def clientTz
      @raw[:clientTz] || 'UTC'
    end

    def table_name
      @model.table_name
    end

    # --- Filters ---

    def negations
      @qis.select{|qi| qi.negation?}
    end

    def exclusions
      @qis.select{|qi| qi.exclusion?}
    end

    def regulars
      @qis.select{|qi| qi.regular_and_valid?}
    end

    def taggables
      @qis.select{|qi| qi.tag_based?}
    end

    def orderings
      @qis.select{|qi| qi.ordering?}
    end

    def qi(name)
      @qis.select{|qi| qi.name == name}.first
    end

    # --- API ---

    def pluck_and_process_negated_attributes
      Hash[negations.collect{|qi| [qi.name, qi.value]}]
    end

    def pluck_and_process_excluded_attributes
      exclusions.collect{|qi| qi.value}
    end

    def pluck_and_process_tag_based_params
      build_query_step_by_step(taggables)
    end

    def pluck_and_process_regular_params
      Hash[regulars.collect{|qi| regular_query(qi)}]
    end

    def pluck_and_process_orderings
      orderings.map do |el|
        replace_attr_if_virt(el.value)
      end
    end

    # =========> Tag based params

    def build_query_step_by_step(qis)
      hash = Hash.new
      qis.each do |qi|
        merge_with_existing_keys(hash, tag_based_query(qi))
      end
      hash
    end

    def tag_based_query(qi)
      case
      when qi.or_value?
        [:any, qi.extract_alternatives]
      when qi.and_value?
        [:all, qi.extract_conjuctions]
      else qi.equals_value?
        [:all, [(qi.value)]]
      end
    end

    # =========> Regular params

    def regular_query(qi)
      case
      when qi.between_value?
        [qi.name, qi.extract_range]
      when qi.or_value?
        [qi.name, qi.extract_alternatives]
      else qi.equals_value?
        [qi.name, qi.value]
      end
    end

    # ========> Helper methods
    def wrap_orderings_to_array(params)
      if (o = params[:order]) && not(o.is_a? Array)
        o = [o]
      end
    end
  
    def replace_attr_if_virt(pair)
      attribute, direction = pair.split
      if VIRT_ATTRS[attribute]
        [VIRT_ATTRS[attribute], direction].join ' '
      else
        [attribute, direction].join ' '
      end
    end

    def merge_with_existing_keys(hash, qi)
      qi_key, qi_val = qi
      if hash[qi_key]
        hash[qi_key] += qi_val
      else
        hash[qi_key] = qi_val
      end
      hash
    end

    def category_name_order
      @name_order ||= YAML::load_file('config/categories_order.yml')['categories']
    end
  end
end
