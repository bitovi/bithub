require_relative 'node'
require 'core_ext'

class BrandInfo < Node
  def initialize(id, name)
    @id = id; @name = name
  end
  attr_reader :id

  def name
    @name.snake_case
  end
  
  def ==(other)
    @id == other.id && @name == other.name
  end

  def to_a
    [id, name]
  end

  def to_s
    ['brand', id].join('/')
  end

  def self.from_s(str)
    self.new(*str.split('/'))
  end
  
  def self.from_msg(msg)
    msg.symbolize_keys!
    self.new(msg.fetch(:id), msg.fetch(:name))
  end
end
