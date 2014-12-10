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

  def self.from_s(str)
    self.new(str)
  end

  alias_method :name, :to_s
end

class MainNode < Node
  def initialize
    @name = 'main'
  end

  def self.from_s(str)
    self.new
  end
end
