class Node
  def initialize(name)
    @name = name
  end
  attr_reader :name

  def to_a
    [@name]
  end

  def to_s
    to_a.join('/')
  end

  def as_node
    [to_s]
  end
  
  def self.deser(str)
    self.new(str)
  end

  alias_method :name, :to_s
end
