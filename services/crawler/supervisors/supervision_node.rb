require_relative 'node_types'

class SupervisionNode
  SEPARATOR = '->'
  LEVELS = [MainInfo, BrandInfo, EmbedInfo, ServiceInfo]

  def self.from_message(nodes)
    if !(curr = nodes.pop).nil?
      node = LEVELS[nodes.length].from_msg(curr)
      SupervisionNode.new(from_message(nodes), node)
    end
  end

  def initialize(parent, node)
    @parent = parent
    @node = node
  end
  attr_reader :node, :parent

  def string_path
    path.map{|n| n.to_s}
  end

  def path
    (root? ? [@node] : @parent.path + [@node]).compact
  end

  def rootless(path_kind = :path)
    send(path_kind)[1..-1]
  end

  def ==(other)
    path == other.path
  end

  def find(type)
    (@node.class == type) ? @node : @parent.find(type)
  end

  def next_level(n)
    SupervisionNode.new(self, n)
  end

  def actor_name
    to_s.to_sym
  end

  def root?
    @parent.nil?
  end

  def to_s
    string_path.join(SEPARATOR)
  end

  # Shortcuts

  def main_info; find(MainInfo); end
  alias_method :brand, :main_info

  def brand_info; find(BrandInfo); end
  alias_method :brand, :brand_info

  def embed_info; find(EmbedInfo); end
  alias_method :embed, :embed_info

  def service_info; find(ServiceInfo); end
  alias_method :service, :service_info
end
