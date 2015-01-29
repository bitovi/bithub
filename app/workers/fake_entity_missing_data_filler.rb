module Workers
  class FakeFollowMissingDataFiller
    include Sidekiq::Worker
    include Sidetiq::Schedulable

    recurrence { minutely(10) }

    def perform
      Brand.pluck(:name).each do |name|
        Apartment::Tenant.switch name do
          Sidekiq.redis do |conn|
            fff = ::Entities::Services::FakeFollowFiller.new(conn)
            fff.fill_missing
          end
        end
      end
    end
  end
end
