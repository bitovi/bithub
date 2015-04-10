module NatlangQueries

  VALID_OPS = %w(contains is)

  class Translator
    def initialize(query, klass = Entity)
      @q = query
      @klass = klass
    end

    def to_ar_query
      { :method => verb, :arg => object }
    end

    def verb
      if @q.op == 'contains'
        :basic_search
      elsif @q.op == 'is'
        :where
      end
    end

    def subject
      if @q.attr == 'content'
        :whole
      elsif @klass.has_an_attribute?(@q.attr)
        @q.attr.to_sym
      end
    end

    def object
      if verb == :basic_search
        @q.val
      elsif verb == :where
        translated_where
      end
    end

    def translated_where
      if @q.negated?
        ["#{subject} <> ?", @q.val]
      else
        ["#{subject} = ?", @q.val]
      end
    end
  end
end
