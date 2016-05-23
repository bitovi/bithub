module NatlangQueries

  VALID_OPS = %w(contains starts_with ends_with contains_phrase contains_any contains_all is)
  SEARCHABLE_ATTRIBUTES = %w(searchable_title searchable_body searchable_content searchable_author)

  OPS_TRANSLATED_TO_LIKE = %w(contains_phrase like starts_with ends_with)
  OPS_TRANSLATED_TO_FULL_TEXT_SEARCH = %w(contains contains_all contains_any)

  class Translator
    def initialize(query, klass = Bit)
      @q = query
      @klass = klass
    end

    def to_ar_query
      { :method => tmethod, :arg => targuments }
    end

    def tmethod
      if op_translated_to_full_text_search?
        :advanced_search
      elsif op == 'is' || op_translated_to_like?
        :where
      end
    end

    def targuments
      if op_translated_to_full_text_search?
        search_arguments
      elsif op == 'is' || op_translated_to_like?
        where_arguments
      end
    end

    def search_arguments
      if attr_is_searchable?
        Hash[attr, search_value]
      else
        search_value
      end
    end

    def where_arguments
      ["#{where_column} #{where_op} ?", where_value]
    end
    
    def where_column
      # "Full text search" doesn't care about attr so it doesn't matter what it's value is
      # In case of "ILIKE search" we translate 'content' to 'body'
      if attribute_defined?
        attr
      end
    end

    def where_op
      if op_translated_to_like?
        @q.negated? ? 'NOT ILIKE' : 'ILIKE'
      elsif op == 'is'
        @q.negated? ? '<>' : '='
      end
    end

    def where_value
      if attribute_defined? && attribute_is_string? && op_translated_to_like?
        if op == 'like' || op == 'contains_phrase'
          '%' + val + '%'
        elsif op == 'is' && attr =~ /author/
          '%' + val + '%'
        elsif op == 'starts_with'
          val + '%'
        elsif op == 'ends_with'
          '%' + val
        end
      else
        val
      end
    end

    def search_value
      if op == 'contains_all' || op == 'contains'
        val.gsub(',','&')
      elsif op == 'contains_any'
        val.gsub(',','|')
      end
    end

    private

    def attr
      if %w(content title body author).include?(@q.attr_name)
        "searchable_#{@q.attr_name}"
      else
        @q.attr_name
      end
    end

    def op
      @q.op
    end

    def val
      @q.val
    end

    def attribute_defined?
      @klass.has_an_attribute?(attr)
    end

    def attribute_is_string?
      %i(string text).include?(@klass.columns_hash[attr.to_s].type)
    end

    def attr_is_searchable?
      SEARCHABLE_ATTRIBUTES.include? attr
    end
    
    def op_translated_to_full_text_search?
      OPS_TRANSLATED_TO_FULL_TEXT_SEARCH.include? @q.op
    end
    
    def op_translated_to_like?
      OPS_TRANSLATED_TO_LIKE.include?(@q.op) || (op == 'is' && attr =~ /author/)
    end
  end
end
