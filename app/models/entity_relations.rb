class EntityRelations

  def initialize(ids)
    @ids = ids.is_a?(Array) ? ids : [ids]
  end

  def children
    if @children_for.nil?
      @children_for = Entity.scoped_with_includes.where(parent_id: @ids)
    end

    @children_for || []
  end

  def children_for_entity(entity)
    children.select{|c| c.parent_id == entity.id}
  end

  def awards_for
    children_ids = children.map {|c| c.id}

    if @awards_for.nil?
      ids = (@ids || []) + (children_ids || [])
      @awards_for = Award.where(applies_to_id: ids)
    end

    @awards_for.all || []
  end

  def funnels_for(entity)
    funnels.select{|f| f.covers?(entity)}.sort{|x,y| y.weight <=> x.weight}.map{|f| f.name}
  end

  def awards_for_entity(entity)
    awards_for.select{|award| award.applies_to_id == entity.id}.first.andand(:value)
  end

  def upvotes_for

    if @upvotes_for.nil?
      @upvotes_for = Upvote.where(applies_to_id: @ids)
    end

    @upvotes_for || []
  end

  def calculate_upvotes_for(entity)
    upvotes = upvotes_for.select{|upvote| upvote.applies_to_id == entity.id }

    if !entity.parent
      entity.respond_to?(:total_upvotes) ? entity.total_upvotes : upvotes.reduce(0) { |acc, u| acc += u.value }
    else
      upvotes.reduce(0) { |acc, u| acc += u.value }
    end
  end

  def thread_awarded(entity)
    if entity.parent_id
      children_ids = children.select {|c| c.parent_id == entity.parent_id}.map {|c| c.id}
    else
      children_ids = children_for_entity(entity).map {|c| c.id}
    end

    awards_for.select {|a| children_ids.include? a.applies_to_id}.size > 0
  end
    
  def funnels
    @funnels ||= Funnel.includes(:constraints).all
  end

end
