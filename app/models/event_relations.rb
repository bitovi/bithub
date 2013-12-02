class EventRelations
  
  def initialize(ids)
    @ids = ids
  end

  def children

    if @children_for.nil?
      @children_for = Event.scoped_with_includes.where(parent_id: @ids)
    end

    @children_for || []
  end

  def children_for_event(event)
    children.select{|c| c.parent_id == event.id}
  end

  def awards_for
    children_ids = children.map {|c| c.id}
    
    if @awards_for.nil?
      @awards_for = Award.where(applies_to_id: [@ids, children_ids].compact)
    end

    @awards_for.all || []
  end

  def awards_for_event(event)
    awards_for.select{|award| award.applies_to_id == event.id}.first.andand(:value)
  end

  def upvotes_for

    if @upvotes_for.nil?
      @upvotes_for = Upvote.where(applies_to_id: @ids)
    end

    @upvotes_for || []
  end

  def calculate_upvotes_for(event)
    upvotes = upvotes_for.select{|upvote| upvote.applies_to_id == event.id }

    if !event.parent
      event.respond_to?(:total_upvotes) ? event.total_upvotes : upvotes.reduce(0) { |acc, u| acc += u.value }
    else
      upvotes.reduce(0) { |acc, u| acc += u.value }
    end
  end

  def thread_awarded(event)
    if event.parent_id
      children_ids = children.select {|c| c.parent_id == event.parent_id}.map {|c| c.id}            
    else
      children_ids = children_for_event(event).map {|c| c.id}      
    end
    
    awards_for.select {|a| children_ids.include? a.applies_to_id}.size > 0
  end

end
