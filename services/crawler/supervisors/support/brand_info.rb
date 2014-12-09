class BrandInfo < Node
  def initialize(id, name)
    @id = id; @name = name
  end
  attr_reader :id, :name
  
  def ==(other)
    @id == other.id && @name == other.name
  end

  def to_a
    [@id, @name]
  end

  def to_s
    to_a.join('/')
  end

  def as_node
    [to_s]
  end
  
  def self.deser(str)
    self.new(*str.split('/'))
  end
end
