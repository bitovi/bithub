class ServiceInfo < Node
  def initialize(id, fn, tn, cfg)
    fail ArgumentError.new('cfg must be a Hash') unless cfg.is_a? Hash
    @id = id
    @feed_name = fn
    @type_name = tn
    @config = cfg
  end
  attr_reader :id, :cfg

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
    self.new(msg.fetch(:id),
      , msg.fetch(:feed_name)
      , msg.fetch(:type_name)
      , msg.fetch(:config)
    )
  end
end
