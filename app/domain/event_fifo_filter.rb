class FIFOFilter

  def initialize
    @queue []
  end



end

new_events = events.reject{|e| @latest.include? e[:content_digest]}
@latest += new_events.collect {|e| e[:content_digest]}
@latest.shift(@latest.length - backlog_size) if (@latest.length > backlog_size)

new_events
