require 'supervisors/propagation'

module Supervisors::Services
  class MockServiceSupervisor
    include Celluloid
    include Supervisors::Propagation

    def initialize(path, service_info); end
    def boot; end
  end

  module Meetup
    class Group < MockServiceSupervisor; end
  end

  module Tumblr
    class Blog < MockServiceSupervisor; end
  end
  
  module Rss
    class Site < MockServiceSupervisor; end
  end
  
  module Stackexchange
    class Tags < MockServiceSupervisor; end
  end
  
  module Github
    class Repo < MockServiceSupervisor; end
  end
end
