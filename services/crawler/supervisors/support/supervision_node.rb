require_relative 'node'
require_relative 'brand_info'
require_relative 'embed_info'
require_relative 'service_info'

class SupervisionNode
  SEPARATOR = '->'
  LEVELS = [Node, BrandInfo, EmbedInfo, ServiceInfo]

  def self.from_message(nodes)
    if (curr = nodes.pop) != nil
      node_info = LEVELS[nodes.length].deser(curr)
      SupervisionNode.new(from_message(nodes), node_info)
    else
      nil
    end
  end

  def initialize(parent, node)
    @parent = parent
    @node = node
  end

  def node
    @node.content
  end
  
  def path
    root? ? @node.as_node : @parent.path + @node.as_node
  end
  
  def rootles_path
    (root? ? [nil] : @parent.rootles_path + @node.as_node).compact
  end

  def ==(other)
    path == other.path
  end

  def find(type)
    (@node.class == type) ? @node : @parent.find(type)
  end

  def next_level(n)
    TreePath.new(self, n)
  end

  def actor_name
    self.to_s.to_sym
  end

  def child_actor_name(n)
    next_level(n).actor_name
  end

  def root?
    @parent.nil?
  end

  def to_s
    path.join(SEPARATOR)
  end

  # Shortcuts

  def brand_info; find(BrandInfo); end
  alias_method :brand, :brand_info

  def embed_info; find(EmbedInfo); end
  alias_method :embed, :embed_info

  def service_info; find(ServiceInfo); end
  alias_method :service, :service_info
end
