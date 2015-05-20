module Workers
  class HistogramFiller
    include Sidekiq::Worker
    include Sidetiq::Schedulable

    # recurrence { minutely.second_of_minute(01, 16, 31, 46) }
    recurrence { hourly.minute_of_hour(01, 16, 31, 46) }

    def perform
      Brand.pluck(:name).each do |name|
        Apartment::Tenant.switch name do
          Histogram.fill_stats
        end
      end
    end
  end
end
