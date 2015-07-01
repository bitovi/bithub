require 'listener/updaters/twitter_updater'
require 'listener/updaters/instagram_updater'

class Updater
  include Celluloid
  include Celluloid::Logger

  CYCLES = [:day]#, :week, :month, :year]
  HEARTBEAT = 15

  def initialize(app_scope = {})
    @redis = ConnectionManager.instance.redis
    every(HEARTBEAT) { update_popularity }
    Celluloid.logger.info "Updater running..."
  end
  attr_reader :redis

  def update_popularity
    CYCLES.each do |c|
      Brand.pluck(:tenant_name).each do |tn|
        Apartment::Tenant.switch(tn) do 
          Celluloid.logger.info "Updating entities for tenant #{tn}"
          TwitterUpdater.new(self, c, tn).update
          InstagramUpdater.new(self, c, tn).update
        end
      end
    end
  end
  
  def cycle_to_lock_duration(cycle)
    if cycle == :day
      30*60
    elsif cycle == :week
      6*60*60
    elsif cycle == :month
      3*24*60*60
    elsif cycle == :year
      15*24*60*60
    end
  end

  def cycle_to_date_range(cycle)
    if cycle == :day
      (Time.now - 1.day + 1)..(Time.now)
    elsif cycle == :week
      (Time.now - 1.week + 1)..(Time.now - 1.day)
    elsif cycle == :month
      (Time.now - 1.month + 1)..(Time.now - 1.week)
    elsif cycle == :year
      (Time.now - 1.year + 1)..(Time.now - 1.month)
    end
  end
end
