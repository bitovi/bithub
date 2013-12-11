class Proc
  def self.compose(f, g)
    lambda { |*args| f[g[*args]] }
  end

  def *(g)
    Proc.compose(self, g)
  end
end

class Hash
  def deep_merge!(other_hash)
    other_hash.each_pair do |k,v|
      tv = self[k]
      self[k] = tv.is_a?(Hash) && v.is_a?(Hash) ? tv.deep_merge(v) : v
    end
    self
  end

  def deep_merge(other_hash)
    dup.deep_merge!(other_hash)
  end
  
  def project(keys)
    keys.map{|k| self[k]}
  end
end

class String
  def snake_case
    self.gsub(/::/, '/').
      .gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
      .gsub(/([a-z\d])([A-Z])/,'\1_\2')
      .tr("-", "_")
      .tr(".", "_")
      .downcase
  end
end

class String
  def to_proc
    Proc.new do |*args|
      split('.').inject(args.shift) do |thing, msg|
        thing = thing.send(msg.to_sym, *args)
      end
    end
  end
end

class Symbol
  def to_proc
    Proc.new {|thing, *args| thing.send(self, *args)}
  end
end

module Enumerable
  def to_proc
    @procs ||= map(&:to_proc)
    Proc.new do |thing, *args|
      @procs.map do |proc|
        proc.call(thing, *args)
      end
    end
  end

  def pluck(*args)
    map(&args)
  end
end
