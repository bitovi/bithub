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
end

class MainNode < Node
  def initialize
    @name = 'main'
  end

  def self.from_s(_)
    self.new
  end

  def self.from_msg(_)
    self.new
  end
end
