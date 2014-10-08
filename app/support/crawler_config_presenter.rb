module Support

  class CrawlerConfigPresenter

    def initialize(service)
      @service = service
      @brand_identities = service.brand_identities
    end

    def present
      present_method_for_feed = "present_#{@service.feed_name}".to_sym
      if @service.config.valid? && respond_to?(present_method_for_feed)
        send(present_method_for_feed)
      end
    end

    def present_github
      {
        access_token: bi_data.andand[:access_token],
        repos: sc_data.andand['repos'] || [],
        orgs: sc_data.andand['orgs'] || []
      }
    end

    def present_facebook
      {
        token: bi_data.data.andand[:access_token],
        pages: sc_data.andand['pages'] || []
      }
    end

    def present_foursquare
      {
        venues: sc_data.andand['venues'].map do |v|
          Hash[:id, v['id']]
        end || []
      }
    end

    def present_disqus
      {
        token: bi_data.andand[:access_token],
        forums: sc_data.andand['forums'].map do |p|
          p['id']
        end
      }
    end

    def present_meetup
      {
        terms: sc_terms,
        token: bi_data.andand[:access_token],
          groups: sc_data.andand['groups'].map do |g|
          g['id']
        end || []
      }
    end

    def present_twitter
      {
        terms: sc_terms,
        identities: bis_data.map do |d|
          {
            access_token: d.andand[:access_token],
            access_secret: d.andand[:access_secret],
          }
        end
      }
    end

    def present_stackexchange
      {
        terms: sc_terms,
        token: bi_data.andand[:access_token],
      }
    end

    def present_instagram
      { subscriptions: sc_data }.merge(bi_data)
    end

    def present_rss
      { sites: sc_data.andand['sites'] || [] }
    end

    def present_irc
      sc_data
    end

    private

    def bis_data
      @brand_identities.map do |bi|
        bi.config.data
      end
    end

    def bi_data
      @brand_identities.first.config.data
    end

    def sc_data
      @service.config.data
    end

    def sc_terms
      @service.config.terms
    end

  end
end
