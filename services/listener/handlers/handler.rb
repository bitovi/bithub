class Handler
  def initialize(listener)
    @listener = listener
  end

  def handle
    fail NotImplementedError
  end
end
