module Workers
  class HistogramFiller
    include Sidekiq::Worker
    include Sidetiq::Schedulable

    recurrence { minutely.second_of_minute(15, 45) }
    # recurrence { hourly.minute_of_hour(15, 45) }

    def perform
      Brand.pluck(:name).each do |name|
        Apartment::Tenant.switch name do
          begin
            Histogram.fill_stats
          rescue ActiveRecord::RecordNotUnique => e
            Rails.logger.info "Too soon"
          end
        end
      end
    end
  end
end
