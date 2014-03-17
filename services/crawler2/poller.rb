class Poller
  include Celluloid

  def initialize(endpoint, interval)
    @endpoint = endpoint
    @interval = interval
    every(interval) { poll }
  end

  def poll
    puts "Polling #{@endpoint}"
  end

end
