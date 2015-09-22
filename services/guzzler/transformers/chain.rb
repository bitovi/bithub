module Guzzler::Transformers
  class Chain
    include Enumerable

    def initialize
      @entries = []
      yield self if block_given?
    end
    attr_reader :entries

    def invoke(data, service)
      retrieve.dup.reduce(data) do |acc, t|
        t.call(acc, service)
      end
    end
    
    def each(&block)
      entries.each(&block)
    end

    def remove(klass)
      entries.delete_if { |entry| entry.klass == klass }
    end

    def add(klass, *args)
      remove(klass) if exists?(klass)
      entries << Entry.new(klass, *args)
    end

    def prepend(klass, *args)
      remove(klass) if exists?(klass)
      entries.insert(0, Entry.new(klass, *args))
    end

    def insert_before(oldklass, newklass, *args)
      i = entries.index { |entry| entry.klass == newklass }
      new_entry = i.nil? ? Entry.new(newklass, *args) : entries.delete_at(i)
      i = entries.index { |entry| entry.klass == oldklass } || 0
      entries.insert(i, new_entry)
    end

    def insert_after(oldklass, newklass, *args)
      i = entries.index { |entry| entry.klass == newklass }
      new_entry = i.nil? ? Entry.new(newklass, *args) : entries.delete_at(i)
      i = entries.index { |entry| entry.klass == oldklass } || entries.count - 1
      entries.insert(i+1, new_entry)
    end

    def exists?(klass)
      any? { |entry| entry.klass == klass }
    end

    def retrieve
      map(&:make_new)
    end

    def clear
      entries.clear
    end
  end
end
