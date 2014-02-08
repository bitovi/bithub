require 'digest/md5'
require 'andand'

class DigestQueue
  class NoDigestError < Exception; end
  attr_reader :backlog_size

  def initialize(initial_events = [], opts = {})
    @backlog_size = opts[:backlog_size] || 10
    @latest_digests = initial_events.andand.map{|e| e[:content_digest]}
  end

  def reject_old(events)
    new_events = events.reject{|e| @latest_digests.include? e[:content_digest]}
    @latest_digests += new_events.collect {|e| e[:content_digest]}
    @latest_digests.shift(total_digests - backlog_size) if (total_digests > backlog_size)

    new_events
  end

  def total_digests
    @latest_digests.length
  end

  def latest
    @latest_digests
  end
end

