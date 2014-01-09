class FIFOFilter

  def initialize
    @queue = []
  end


  def reject_old
    new_events = events.reject{|e| @queue.include? e[:content_digest]}
    @queue += new_events.collect {|e| e[:content_digest]}
    @queue.shift(@queue.length - backlog_size) if (@queue.length > backlog_size)

    new_events
  end

end

