module Workers
  class FakeFollowMissingDataFiller
    include Sidekiq::Worker
    include Sidetiq::Schedulable

    recurrence { minutely }

    def perform
      Brand.pluck(:name).each do |name|
        Apartment::Tenant.switch name do
          Sidekiq.redis do |conn|
            fff = ::Entities::Services::FakeFollowFiller.new(conn)

            if fff.user_ids_with_missing_names.count >= 10
              fff.fill_missing
            else
              Rails.logger.info "Not enough empty Follow entities to init processing"
            end
          end
        end
      end
    end
  end
end
