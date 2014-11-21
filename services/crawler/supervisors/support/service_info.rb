class ServiceInfo
  def initialize(fn, tn)
    @feed_name = fn; @type_name = tn
  end
  attr_reader :feed_name, :type_name, :composed

  def to_s
    [@feed_name, @type_name].join('_')
  end

  def to_a
    [@feed_name, @type_name]
  end
  alias_method :name, :to_s
end
