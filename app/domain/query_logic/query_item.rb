module QueryLogic
  class QueryItem
    attr_reader :name, :value
    TAG_FIELD_NAMES = ['tag', 'feed', 'category', 'project']

    DELIMITERS = { :and => ',', :or => '|', :between => ':' }
    OPTIONAL_LOGIC = { :exclude => 'exclude' }
    NEGATION = '!'

    def initialize(model, param)
      @model = model
      @name, @value = param
    end

    def value
      if negation? 
        @value.gsub(/^!(.*)$/, '\1')
      elsif ordering?
        @value.gsub(':', ' ')
      else
        @value
      end
    end

    def regular_and_valid?
      native? and not(negation?) and not(tag_based?)
    end

    def between_value?
      @value.include?(DELIMITERS[:between])
    end

    def or_value?
      @value.include?(DELIMITERS[:or])
    end

    def and_value?
      @value.include?(DELIMITERS[:and]) || @value.is_a?(Array)
    end

    def negation?
      native? && @value[0] == NEGATION
    end

    def exclusion?
      OPTIONAL_LOGIC[:exclude] == @name || OPTIONAL_LOGIC[:exclude] == @name.to_s
    end

    def ordering?
      (@name =~ /order/) && ((@value.include? ':desc') || (@value.include? ':asc'))
    end

    def tag_based?
      if @model.respond_to? :tag_based_attrs
        @model.tag_based_attrs.include?(@name.to_s)
      else
        TAG_FIELD_NAMES.include?(@name.to_s)
      end
    end

    def equals_value?
      true
    end

    def extract_range
      lower_str, higher_str = @value.split(DELIMITERS[:between])
      column_type = @model.columns_hash[@name.to_s].type
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

    def extract_alternatives
      @value.split(DELIMITERS[:or])
    end

    def extract_conjuctions
      @value.is_a?(Array) ? @value : @value.split(DELIMITERS[:and])
    end

    def native?
      @model.respond_to?(:has_an_attribute?) && @model.has_an_attribute?(@name)
    end
  end
end
