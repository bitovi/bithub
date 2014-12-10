require_relative 'node'

class EmbedInfo < Node
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

  def self.from_s(str)
    self.new(*str.split('/'))
  end
end
