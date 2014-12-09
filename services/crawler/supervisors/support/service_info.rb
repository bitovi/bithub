class ServiceInfo < Node
  def initialize(id, fn, tn)
    @id = id;
    @feed_name = fn; @type_name = tn
  end
  attr_reader :id, :feed_name, :type_name
  
  def ==(other)
    @id == other.id\
      && @feed_name == other.feed_name\
      && @type_name == other.type_name
  end

  def to_a
    [@id, @feed_name, @type_name]
  end

  def to_s
    [@id, [@feed_name, @type_name].join('_')].join('/')
  end

  def as_node
    [to_s]
  end

  def self.deser(str)
    id, fwt = str.split('/')
    feed_name, type_name = fwt.split('_')
    self.new(id, feed_name, type_name)
  end
end
