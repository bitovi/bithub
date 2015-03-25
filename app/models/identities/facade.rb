module Identities
  class Facade

    def initialize(facade, sd, ed)
      @facade = facade.new(ed)
      @provider_name = facade.name.gsub('Identities::Facades::', '').downcase
      @source_data = sd
      @extracted_data = ed
    end

    def credentials(property_id = nil)
      if @provider_name == 'facebook' && (page_id = property_id)
        { access_token: @facade.page_token(page_id) }
      elsif @provider_name == 'twitter'
        { access_token: access_token, access_secret: access_secret }
      else
        { access_token: access_token }
      end
    end

    def property_id_name_pairs(type = nil)
      if @provider_name == 'github' && type == 'repo'
        @facade.repo_ids_and_names
      elsif @provider_name == 'github' && type == 'org'
        @facade.org_ids_and_names
      elsif @provider_name == 'disqus'
        @facade.forum_ids_and_names
      elsif @provider_name == 'facebook'
        @facade.page_ids_and_names
      elsif @provider_name == 'meetup'
        @facade.group_ids_and_names
      elsif @provider_name == 'foursquare'
        @facade.venue_ids_and_names
      end
    end

    def property_name_for_id(id)
      case @provider_name
      when 'facebook'
        @facade.page_name_for_id(id)
      when 'meetup'
        @facade.group_name_for_id(id)
      when 'foursquare'
        @facade.venue_name_for_id(id)
      end
    end

    class Protocol
      def initialize(ed)
        @extracted_data = HashWithIndifferentAccess.new ed
      end
    end

    private
    def access_token
      @extracted_data[:access_token]
    end

    def access_secret
      @extracted_data[:access_secret]
    end
  end
end
