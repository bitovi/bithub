require 'util'

module Guzzler

  class Job

    def initialize(service_data)
      @data = JSON.parse(service_data)
    end
    attr_accessor :data

    def interval
      @data['interval'] || 60.0
    end

    def config
      @data['config']
    end

    def to_json
      @data.to_json
    end
  end


  class Fetcher
    include Util
    include Celluloid

    TIMEOUT = 1

    def initialize
      @shutdown = nil
    end

    attr_accessor :manager

    def fetch
      watchdog('Fetcher#fetch died') do
        return if Fetcher.shutdown?

        begin
          if job = retrieve_job
            @manager.async.assign(job)
          else
            after(5) { fetch }
          end
        rescue => ex
          raise ex
          # handle_fetch_exception(ex)
        end
      end
    end

    def retrieve_job
      job = nil
      now = Time.now.to_f

      Guzzler.redis do |conn|
        conn.watch(schedule_key) do
          service_key, score = conn.zrangebyscore(schedule_key, '-inf', now, { :limit => [0, 1], :with_scores => true }).first
          if service_key && score
            if service_data = conn.redis.get(service_key)
              job = Job.new(service_data)
              conn.zincrby(schedule_key, (now - score + job.interval), service_key)
            end
          end
        end
      end

      job
    end

    private

    def schedule_key
      'schedule'
    end

    # def handle_fetch_exception(ex)
    #   puts("Error fetching message: #{ex}")
    #   pause
    #   after(0) { fetch }
    # end

    # def pause
    #   sleep(TIMEOUT)
    # end

    def self.shutdown?
      defined?(@shutdown) && @shutdown
    end

  end
end

