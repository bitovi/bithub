class NatlangQueryTranslator

  def initialize(query, klass = Entity)
    @q = query
    @klass = klass
  end

  def to_ar_query
  end

  def verb
    if @q.op == 'contains'
      :basic_search
    elsif @q.op == 'tagged_with'
      :tagged_with
    elsif @q.op == 'is'
      :'='
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
    if @q.op == 'contains'
      @q.val.split(',')
    elsif @q.op == 'tagged_with'
      @q.val
    end
  end

end
