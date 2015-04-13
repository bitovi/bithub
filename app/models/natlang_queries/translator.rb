module NatlangQueries

  VALID_OPS = %w(contains contains_any contains_all is)

  class Translator
    def initialize(query, klass = Entity)
      @q = query
      @klass = klass
    end

    def to_ar_query
      { :method => verb, :arg => object }
    end

    def verb
      if full_text_search?
        :advanced_search
      elsif @q.op == 'is'
        :where
      end
    end

    def subject
      if @q.attr_name == 'content'
        :whole
      elsif @klass.has_an_attribute?(@q.attr_name)
        @q.attr_name.to_sym
      end
    end

    def object
      if full_text_search?
        translated_advanced_search
      elsif @q.op == 'is'
        translated_where
      end
    end

    def translated_advanced_search
      if @q.attr_name == 'content'
        full_text_op_to_object
      else
        h = { }; h[@q.attr_name] = full_text_op_to_object; h
      end
    end

    def translated_where
      if @q.negated?
        ["#{subject} <> ?", @q.val]
      else
        ["#{subject} = ?", @q.val]
      end
    end

    def full_text_op_to_object
      if @q.op == 'contains_all' || @q.op == 'contains'
        @q.val.gsub(',','&')
      elsif @q.op == 'contains_any'
        @q.val.gsub(',','|')
      end
    end

    def full_text_search?
      %w(contains contains_all contains_any).include? @q.op
    end
  end
end
