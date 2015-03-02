require 'core_ext'

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

class MainInfo < Node
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

class EmbedInfo < Node
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
    ['embed', id].join('/')
  end

  def self.from_s(str)
    self.new(*str.split('/'))
  end

  def self.from_msg(msg)
    msg.symbolize_keys!
    self.new(msg.fetch(:id), msg.fetch(:name))
  end
end

class ServiceInfo < Node
  def initialize(id, fn, tn)
    @id = id; @feed_name = fn; @type_name = tn
  end
  attr_reader :id

  def feed_name; @feed_name.downcase; end
  def type_name; @type_name.downcase; end
  
  def ==(other)
    @id == other.id\
      && @feed_name == other.feed_name\
      && @type_name == other.type_name
  end

  def to_a
    [@id, feed_name, type_name]
  end

  def to_s
    ['service', id].join('/')
  end

  def self.from_s(str)
    id, fwt = str.split('/')
    feed_name, type_name = fwt.split('_')
    self.new(id, feed_name, type_name)
  end
  
  def self.from_msg(msg)
    msg.symbolize_keys!
    self.new(msg.fetch(:id), msg.fetch(:feed_name), msg.fetch(:type_name))
  end
end

class EndpointInfo < Node
  def initialize(type = nil, id)
    @type = type
    @id = id
  end
  attr_reader :type
  
  def id
    @id
  end
  alias_method :name, :id

  def ==(other)
    @id == other.id && @type == other.type
  end

  def to_a
    [type, id]
  end

  def to_s
    [['brand', type].compact.join('/'), id].join('_')
  end

  def self.from_s(str)
    fail "shouldn't ever be here"
  end

  def self.from_msg(msg)
    fail "shouldn't ever be here"
  end
end
