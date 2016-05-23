class BitRelations

  def initialize(ids)
    @ids = ids.is_a?(Array) ? ids : [ids]
  end

  def children
    if @children_for.nil?
      @children_for = Bit.scoped_with_includes.where(parent_id: @ids)
    end

    @children_for || []
  end

  def children_for_bit(bit)
    children.select{|c| c.parent_id == bit.id}
  end

  def funnels_for(bit)
    funnels.select{|f| f.covers?(bit)}.sort{|x,y| y.weight <=> x.weight}.map{|f| f.name}
  end

  def funnels
    @funnels ||= Funnel.includes(:constraints).all
  end

end
