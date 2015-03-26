module Identities
  class Facade

    def initialize(facade, sd, ed)
      @source_data = HashWithIndifferentAccess.new sd
      @extracted_data = HashWithIndifferentAccess.new ed
      @provider_facade = facade.new(@source_data, @extracted_data)
    end

    def name
      if %w(github twitter).include? @provider_facade.provider_name
        @source_data['info']['nickname']
      elsif %w(facebook disqus meetup foursquare).include? @provider_facade.provider_name
        @source_data['info']['name']
      end
    end

    def credentials(property_id = nil)
      if @provider_facade.provider_name == 'facebook' && (page_id = property_id)
        { access_token: @provider_facade.page_token(page_id) }
      elsif @provider_facade.provider_name == 'twitter'
        { access_token: access_token, access_secret: @provider_facade.access_secret }
      else
        { access_token: access_token }
      end
    end

    def property_id_name_pairs(property_type = nil)
      if @provider_facade.provider_name == 'github' && property_type== 'repo'
        @provider_facade.repo_ids_and_names
      elsif @provider_facade.provider_name == 'github' && property_type == 'org'
        @provider_facade.org_ids_and_names
      else
        @provider_facade.property_id_name_pairs
      end
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
