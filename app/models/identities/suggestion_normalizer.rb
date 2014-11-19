module Identities
  class SuggestionNormalizer

    def initialize(brand_ident)
      @bi = brand_ident
      @feed_name = brand_ident.provider
    end

    def normalize(type_name)
      normalization_method = "normalize_#{@feed_name}_#{type_name}".to_sym
      if respond_to? normalization_method
        send(normalization_method)
      else
        @bi
      end
    end

    def normalize_meetup_group
      Hash[@bi.source_data.fetch('groups').map do |g|
        [g.fetch('id'), g.fetch('name')]
      end]
    end

    def normalize_disqus_forum
      Hash[@bi.source_data.fetch('forums').map do |g|
        [g.fetch('id'), g.fetch('name')]
      end]
    end
    
    def normalize_github_repo
      Hash[@bi.source_data.fetch('repos').map do |g|
        [g.fetch('id'), g.fetch('full_name')]
      end]
    end

    def normalize_github_org
      Hash[@bi.source_data.fetch('orgs').map do |g|
        [g.fetch('id'), g.fetch('login')]
      end]
    end
    
    def normalize_facebook_page
      Hash[@bi.source_data.fetch('pages').map do |g|
        [g.fetch('id'), g.fetch('name')]
      end]
    end
    
    def normalize_foursquare_venue
      Hash[@bi.source_data.fetch('venues').map do |g|
        [g.fetch('id'), g.fetch('name')]
      end]
    end
  end
end
