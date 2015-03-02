class MainInfo < Node
  def initialize
    @name = 'main'
  end

  def self.from_s(_)
    self.new
  end

  def self.from_msg(_)
    self.new
  end
end
