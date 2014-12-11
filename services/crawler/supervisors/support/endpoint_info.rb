require_relative 'node'

class EndpointInfo < Node
  def initialize(name)
    @name = name
  end
  attr_reader :name
  
  def name
    @name.snake_case
  end

  def ==(other)
    @name == other.name
  end

  def to_a
    [name]
  end

  def to_s
    ['endpoint', name].join('/')
  end

  def self.from_s(str)
    fail "shouldn't ever be here"
  end

  def self.from_msg(msg)
    fail "shouldn't ever be here"
  end
end
