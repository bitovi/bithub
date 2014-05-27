module Tagger
  class Tag
    #class InvalidTagDefinitionException < Exception; end

    DEFAULT_TOLERANCE = 1
    DEFAULT_WEIGHT    = 1

    attr_reader :name, :tolerance, :aliases, :weight

    def initialize(tag)
      # convert string to hash
      tag = {name: tag} if tag.kind_of?(String)

      @name      = tag[:name]
      @aliases   = tag[:aliases] || []
      @tolerance = tag[:tolerance].to_i || DEFAULT_TOLERANCE
      @weight    = tag[:weight].to_i || DEFAULT_WEIGHT
    end

    def names
      [@name] + @aliases
    end
  end
end
