module Accounts
  class FakeDigestsCreator

    class CreateFakeDigestsJob < Struct.new(:ident_uid)
      def perform
        if (ident = Identity.find_by_uid(ident_uid))
          FakeDigestsCreator.new(ident).execute
        end
      end
    end

    def initialize(ident)
      @identity = ident
    end

    def execute
      create_missing_repos_and_stars
    end

    def async_execute
      Delayed::Job.enqueue CreateFakeDigestsJob.new(@identity.uid)
    end

    def create_missing_repos_and_stars
      Rails.logger.info "KURAC #{@identity.inspect}"
      if @identity.provider == 'twitter'
        create_custom_follows
      elsif @identity.provider == 'github'
        create_custom_stars
      end
    end

    def create_custom_follows
      ApiCache.where(provider: @identity.provider, uid: @identity.uid.to_s).each do |res|
        data = {
          source_data: {
            uid: @identity.uid,
            nickname: @identity.nickname,
            target_screen_name: res.name,
            custom_follow: true,
          },
        }
        Dispatcher.new.dispatch(data, @identity.provider)
      end
    end

    def create_custom_stars
      ApiCache.where(provider: @identity.provider, uid: @identity.uid.to_s).each do |res|
        data = {
          source_data: {
            uid: @identity.uid,
            nickname: @identity.nickname,
            repo_name: res.name,
            custom_watch: true,
          }
        }
        Dispatcher.new.dispatch(data, @identity.provider)
      end
    end

  end
end
