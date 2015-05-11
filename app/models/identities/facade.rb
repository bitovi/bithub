module Identities
  class Facade

    def initialize(facade, sd, ed)
      @source_data = HashWithIndifferentAccess.new sd
      @extracted_data = HashWithIndifferentAccess.new ed
      @provider_facade = facade.new(@source_data, @extracted_data)
    end

    def name
      if %w(github twitter instagram).include? @provider_facade.provider_name
        @source_data['info']['nickname']
      elsif %w(facebook disqus meetup foursquare google_oauth2).include? @provider_facade.provider_name
        @source_data['info']['name']
      end
    end

    def credentials(property_id = nil)
      if @provider_facade.provider_name == 'facebook' && (page_id = property_id)
        _access_token = (@provider_facade.page_token(page_id) || @provider_facade.user_long_lived_token)
        { access_token: _access_token }
      elsif @provider_facade.provider_name == 'twitter'
        { access_token: access_token, access_secret: @provider_facade.access_secret }
      elsif @source_data[:credentials]
        { access_token: access_token }
      else
        {}
      end
    end

    def property_id_name_pairs(property_type=nil)
      @provider_facade.property_id_name_pairs property_type
    end

    def property_name_for_id(id)
      case @provider_facade.provider_name
      when 'facebook'
        @provider_facade.page_name_for_id(id)
      when 'meetup'
        @provider_facade.group_name_for_id(id)
      when 'foursquare'
        @provider_facade.venue_name_for_id(id)
      end
    end

    class Protocol
      def initialize(sd, ed)
        @source_data = HashWithIndifferentAccess.new sd
        @extracted_data = HashWithIndifferentAccess.new ed
      end

      def provider_name
        self.class.to_s.gsub('Identities::Facades::', '').downcase
      end
    end

    private

    def access_token
      @source_data.fetch(:credentials).fetch(:token)
    end
  end
end
