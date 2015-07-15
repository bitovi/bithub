require 'nokogiri'
require 'open-uri'

module Services
  module Types
    module Rss

      class Site
        include Virtus.model(:strict => true)
        attribute :url, String
        attribute :tag_with, String, required: false, default: lambda { |obj, attr| obj.url_as_tag(obj.url) }

        def url=(url)
          response = open(url)

          if response.meta['content-type'].starts_with? 'text/html'
            page = Nokogiri::HTML response
            if rss_url = page.css("link[type='application/rss+xml']").first
              url = rss_url['href'].starts_with?('/') ? File.join(url, rss_url['href']) : rss_url['href']
            end
          end

          super url
        end

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
