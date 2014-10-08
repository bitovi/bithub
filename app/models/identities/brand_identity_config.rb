module Identities

  class BrandIdentityConfig

    def initialize(source_data, provider_name)
      @data = source_data
      @provider_name = provider_name
    end

    def builder_class
      @builder_class ||= ::Identities::Builders\
        .const_get(@provider_name.camel_case)
    end

    def builder
      @builder ||= builder_class.new(@data)
    end

    def data
      data_assembling_method = "data_#{@provider_name}".to_sym
      send(data_assembling_method) if respond_to?(data_assembling_method)
    end

    def data_github
      {
        info: builder.info,
        access_token: builder.access_token,
        repos: builder.repo_names,
        orgs: builder.org_names
      }
    end

    def data_facebook
      {
        info: builder.info,
        access_token: builder.access_token,
        pages: builder.pages.map do |p|
          {id: p[:id], access_token: p[:access_token], name: p[:name]}
        end
      }
    end

    def data_twitter
      {
        info: builder.info,
        access_token: builder.access_token,
        access_secret: builder.access_secret
      }
    end

    def data_disqus
      {
        info: builder.info,
        access_token: builder.access_token,
        forums: builder.forum_names_and_ids
      }
    end

    def data_foursquare
      {
        info: builder.info,
        access_token: builder.access_token
      }
    end

    def data_meetup
      {
        info: builder.info,
        access_token: builder.access_token,
        groups: builder.group_names_and_ids
      }
    end

    def data_stackexchange
      {
        info: builder.info,
        access_token: builder.access_token
      }
    end

    def data_instagram
      {
        info: builder.info,
        access_token: builder.access_token
      }
    end
  end
end
