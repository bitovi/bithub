module Workers
  class FacebookPhotoSourceFiller
    include Sidekiq::Worker
    include Sidetiq::Schedulable

    recurrence { minutely(10) }

    def perform
      Brand.pluck(:name).each do |name|
        Apartment::Tenant.switch name do

          Embed.all.each do |e|
            e.services.where(feed_name: 'facebook').each do |s|
              access_token = s.credentials.fetch(:access_token)
              client = Koala::Facebook::API.new access_token

              ::Entities::Services::FacebookPhotoSourceFiller.new(s, client).fill
            end
          end

        end
      end
    end
  end
end
