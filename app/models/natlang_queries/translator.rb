module NatlangQueries

  VALID_OPS = %w(contains starts_with ends_with contains_phrase contains_any contains_all is)
  SEARCHABLE_ATTRIBUTES = %w(content title body author)

  class Translator
    def initialize(query, klass = Entity)
      @q = query
      @klass = klass
    end

    def to_ar_query
      { :method => tmethod, :arg => targuments }
    end

    def op_translated_to_full_text_search?
      %w(contains contains_all contains_any).include? @q.op
    end

    def op_translated_to_like?
      %w(contains_phrase like starts_with ends_with).include? @q.op
    end

    def attribute_defined?
      @q.attr_name == 'content' || @klass.has_an_attribute?(@q.attr_name)
    end

    def attribute_is_string?
      @q.attr_name == 'content' || (%i(string text).include? @klass.columns_hash[@q.attr_name].type)
    end

    def tmethod
      if op_translated_to_full_text_search?
        :advanced_search
      elsif @q.op == 'is' || op_translated_to_like?
        :where
      end
    end

    def targuments
      if op_translated_to_full_text_search?
        search_arguments
      elsif @q.op == 'is' || op_translated_to_like?
        where_arguments
      end
    end

    def search_arguments
      if SEARCHABLE_ATTRIBUTES.include? @q.attr_name
        Hash[search_attr, search_value]
      else
        search_value
      end
    end

    def where_arguments
      ["#{where_column} #{where_op} ?", where_value]
    end
    
    def where_column
      # "Full text search" doesn't care about attr_name so it doesn't matter what it's value is
      # In case of "ILIKE search" we translate 'content' to 'body'
      if @q.attr_name == 'content'
        'body'
      elsif attribute_defined?
        @q.attr_name
      end
    end

    def where_op
      if @q.op == 'is'
        @q.negated? ? '<>' : '='
      elsif op_translated_to_like?
        @q.negated? ? 'NOT ILIKE' : 'ILIKE'
      end
    end

    def where_value
      if (x = attribute_defined?) && (y = attribute_is_string?) && (z = op_translated_to_like?)
        if @q.op == 'like' || @q.op == 'contains_phrase'
          '%' + @q.val + '%'
        elsif @q.op == 'starts_with'
          @q.val + '%'
        elsif @q.op == 'ends_with'
          '%' + @q.val
        end
      else
        @q.val
      end
    end

    def search_attr
      if SEARCHABLE_ATTRIBUTES.include? @q.attr_name
        'searchable_' + @q.attr_name
      end
    end

    def search_value
      if @q.op == 'contains_all' || @q.op == 'contains'
        @q.val.gsub(',','&')
      elsif @q.op == 'contains_any'
        @q.val.gsub(',','|')
      end
    end

  end
end
