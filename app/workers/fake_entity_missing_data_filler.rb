module Workers
  class FakeFollowMissingDataFiller
    include Sidekiq::Worker
    include Sidetiq::Schedulable
    
    recurrence { minutely }

    def perform
      Brand.pluck(:name).each do |name| 
        Apartment::Database.switch(name)
        fff = Entities::Services::FakeFollowFiller.new

        if fff.follows_with_missing_name.count >= 50
          fff.fill_missing
        else
          Rails.logger.info "Not enough empty Follow entities to init processing"
        end
      end
      Apartment::Database.switch('public')
    end
  end
end
