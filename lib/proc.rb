class Proc
  def self.compose(f, g)
    lambda { |*args| f[g[*args]] }
  end

  def *(g)
    Proc.compose(self, g)
  end
end
