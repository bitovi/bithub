module Workers
  class HistogramFiller
    include Sidekiq::Worker
    include Sidetiq::Schedulable

    # recurrence { minutely.second_of_minute(01, 16, 31, 46) }
    recurrence { hourly.minute_of_hour(01, 16, 31, 46) }

    def perform
      Brand.pluck(:name).each do |name|
        Apartment::Tenant.switch name do
          begin
            Histogram.fill_stats
          rescue ActiveRecord::RecordNotUnique => e
            Rails.logger.info "Job for filling the the Histogram table started too soon"
          rescue ActiveRecord::StatementInvalid => e
            Rails.logger.error e.message
          end
        end
      end
    end
  end
end
