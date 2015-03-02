require 'core_ext'
require 'main_info'
require 'brand_info'
require 'embed_info'
require 'service_info'
require 'endpoint_info'

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
