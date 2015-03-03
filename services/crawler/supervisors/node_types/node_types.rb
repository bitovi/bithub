require 'core_ext'

module NodeTypes
  class Node
    include Comparable

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

    def klassname
      self.class.name.gsub('NodeTypes::', '').gsub('Info', '')
    end

    def <=>(other)
      if self.class == other.class
        0
      else
        if is_a?(MainInfo)
          -1
        elsif is_a?(BrandInfo)
          other.is_a?(MainInfo) ? 1 : -1
        elsif is_a?(EmbedInfo)
          other.is_a?(ServiceInfo) ? -1 : 1
        elsif is_a?(ServiceInfo)
          1
        end
      end
    end
  end
end

require 'supervisors/node_types/main_info'
require 'supervisors/node_types/brand_info'
require 'supervisors/node_types/embed_info'
require 'supervisors/node_types/service_info'
require 'supervisors/node_types/endpoint_info'
