class Proc
  def self.compose(f, g)
    lambda { |*args| f[g[*args]] }
  end

  def *(g)
    Proc.compose(self, g)
  end
end

class Hash
  def deep_merge!(other_hash = nil)
    other_hash.each_pair do |k,v|
      tv = self[k]
      self[k] = tv.is_a?(Hash) && v.is_a?(Hash) ? tv.deep_merge(v) : v
    end if other_hash
    self
  end

  def deep_merge(other_hash = nil)
    dup.deep_merge!(other_hash)
  end
  
  def project(keys)
    keys.map{|k| self[k]}
  end

  def symbolize_keys!
    keys.each do |key|
      self[(key.to_sym rescue key) || key] = delete(key)
    end
    self
  end

  def symbolize_keys
    dup.symbolize_keys!
  end
end

class String
  def snake_case
    #gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr('-', '_').
    gsub(/\s/, '_').
    gsub(/__+/, '_').
    downcase
  end

  def camel_case
    return self if self !~ /_/ && self =~ /[A-Z]+.*/
    split('_').map{|e| e.capitalize}.join
  end

  def to_proc
    Proc.new do |*args|
      split('.').inject(args.shift) do |thing, msg|
        thing = thing.send(msg.to_sym, *args)
      end
    end
  end

  # Only parses twice if url doesn't start with a scheme
  def main_domain
    uri = URI.parse(self)
    uri = URI.parse("http://#{self}") if uri.scheme.nil?
    host = uri.host.downcase
    host.start_with?('www.') ? host[4..-1] : host
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
      end unless  @procs.nil?
    end
  end

  def pluck(*args)
    map(&args)
  end
end
