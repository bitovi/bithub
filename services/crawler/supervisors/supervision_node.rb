require 'supervisors/node_types/node_types'

class SupervisionNode
  SEPARATOR = '->'

  def self.from_message(msg)
    tree_from_nodes(nodes_from_message(msg))
  end

  def self.nodes_from_message(msg)
    msg.merge({main: {}}).select do |key, val|
      val.respond_to? :values
    end.map do |key, hsh|
      NodeTypes.const_get((key.to_s + '_info').camel_case).from_message(hsh)
    end.compact.sort
  end

  def self.tree_from_nodes(nodes)
    if !(curr = nodes.pop).nil?
      SupervisionNode.new(tree_from_nodes(nodes), curr)
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

  def depth
    path.length-1
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

  def to_log_format
    "#{brand_info.id},#{embed_info.id},#{service_info.id},#{service_info.feed_name},#{service_info.type_name}"
  end

  def to_h
    {
      brand_id: brand_info.id,
      brand_name: brand_info.name,
      embed_id: embed_info.id,
      embed_name: embed_info.name,
      service_id: service_info.id,
      feed_name: service_info.feed_name,
      type_name: service_info.type_name
    }
  end

  # Shortcuts

  def main_info; find(NodeTypes::MainInfo); end
  alias_method :brand, :main_info

  def brand_info; find(NodeTypes::BrandInfo); end
  alias_method :brand, :brand_info

  def embed_info; find(NodeTypes::EmbedInfo); end
  alias_method :embed, :embed_info

  def service_info; find(NodeTypes::ServiceInfo); end
  alias_method :service, :service_info
end
