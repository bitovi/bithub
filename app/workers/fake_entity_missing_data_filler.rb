module Workers
  class FakeFollowMissingDataFiller
    include Sidekiq::Worker
    include Sidetiq::Schedulable

    recurrence { hourly.minute_of_hour(0, 10, 20, 30, 40, 50) }

    def perform
      Brand.pluck(:name).each do |name|
        Apartment::Tenant.switch name do
          Sidekiq.redis do |conn|
            fff = Workers::Support::FakeFollowFiller.new(conn)
            fff.fill_missing
          end
        end
      end
    end
  end
end
