module Services
  module Types
    module Rss
      class Site
        include Virtus.model(:strict => true)
        attribute :url, String
        attribute :tag_with, String, required: false, default: lambda { |obj, attr| obj.url_as_tag(obj.url) }

        def url_as_tag(url)
          url = url.sub(/^https?\:\/\//, '').sub(/^www./,'')
          url.downcase.gsub(/'/, '').gsub(/[^a-z0-9]+/, '-') do |slug|
            slug.chop! if slug.last == '-'
          end
        end
      end
    end
  end
end
