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

  def funnels_for(entity)
    funnels.select{|f| f.covers?(entity)}.sort{|x,y| y.weight <=> x.weight}.map{|f| f.name}
  end

  def funnels
    @funnels ||= Funnel.includes(:constraints).all
  end

end
