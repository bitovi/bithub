module NodeTypes
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
      [['b', type].compact.join('/'), id].join('_')
    end

    def self.from_s(str)
      fail "shouldn't ever be here"
    end

    def self.from_message(msg)
      fail "shouldn't ever be here"
    end
  end
end
