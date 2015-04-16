module NatlangQueries

  VALID_OPS = %w(contains contains_any contains_all is)

  class Translator
    def initialize(query, klass = Entity)
      @q = query
      @klass = klass
    end

    def to_ar_query
      { :method => tmethod, :arg => targuments }
    end

    def op_is_contains?
      %w(contains contains_all contains_any).include? @q.op
    end

    def tmethod
      if op_is_contains? && @q.attr_name != 'author'
        :advanced_search
      elsif op_is_contains? && @q.attr_name == 'author'
        :where
      elsif @q.op == 'is'
        :where
      end
    end

    def targuments
      if op_is_contains? && @q.attr_name != 'author'
        search_arguments
      elsif op_is_contains? && @q.attr_name == 'author'
        where_arguments
      elsif @q.op == 'is'
        where_arguments
      end
    end

    def search_arguments
      if @q.attr_name == 'content'
        search_value
      else
        h = { }; h[@q.attr_name] = search_value; h
      end
    end

    def where_arguments
      ["#{where_column} #{where_op} ?", where_value]
    end
    
    def where_column
      if @q.attr_name == 'author'
        "props -> 'origin_author_name'"
      elsif @klass.has_an_attribute?(@q.attr_name)
        @q.attr_name
      end
    end

    def where_op
      if @q.op == 'is'
        @q.negated? ? '<>' : '='
      elsif @q.op =~ /contains/
        @q.negated? ? 'NOT LIKE' : 'LIKE'
      end
    end

    def where_value
      if @q.attr_name == 'author' && @q.op =~ /contains/
        '%' + @q.val + '%'
      else
        @q.val
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
