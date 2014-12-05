require_relative 'service_info'

class TreePath
  SEPARATOR = '->'
  LEVELS = [:root, :brand_name, :embed_name, :service_info]

  def self.from_message(nodes)
    if (curr = nodes.pop) != nil
      node = curr.include?('+') ? ServiceInfo.new(*curr.split('+')) : curr
      lvl = LEVELS[nodes.length]
      TreePath.new(from_message(nodes), node, lvl)
    else
      nil
    end
  end

  def initialize(parent, node_content, node_type = :tmp)
    @parent = parent
    @node = Node.new(node_content, node_type)
  end

  def node
    @node.content
  end
  
  def path
    root? ? @node.to_a : @parent.path + @node.to_a
  end

  def ==(other)
    path == other.path
  end

  def rootles_path
    (root? ? [nil] : @parent.rootles_path + @node.to_a).compact
  end

  def find(type)
    (@node.type == type) ? @node.content : @parent.find(type)
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

  def brand_name
    find(:brand_name)
  end
  alias_method :brand, :brand_name

  def embed_name
    find(:embed_name)
  end
  alias_method :embed, :embed_name

  def service_info
    find(:service_info)
  end

  def service_name
    find(:service_info).to_s
  end

  def service_feed
    find(:service_info).feed_name
  end
  
  def service_type
    find(:service_info).type_name
  end
  
  class Node
    def initialize(content, type)
      @content = content; @type = type
    end
    attr_reader :content, :type

    def to_a
      @content.respond_to?(:to_a) ? @content.to_a : [@content]
    end

    def to_s
      @content.to_s
    end
  end
end
