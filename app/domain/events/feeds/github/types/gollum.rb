module Events
  module Github

    class Gollum
      include Constructable
      include Events::Github::StandardAccessors

      def pages
        payload.andand[:pages]
      end

      def page_titles
        pages.map(&:title)
      end

      def page_urls
        pages.map(&:html_url)
      end
    end

  end
end

# new_data = {
#   extracted: {
#     :title => "wiki updated on #{original_hash['repo']['name']}",
#   },
#   meta: { :pages => [] }
# }

# original_hash['payload']['pages'].each do |page|
#   new_data[:meta][:pages].push({:title => page['title'], :url => page['html_url']})
# end

# processed.deep_merge(new_data)
#
#
# NEW _-____________
# def titles_urls
#   titles = [:title].product(page_titles)
#   urls = [:url].product(page_urls)

#   titles.zip(urls).map {|r| Hash[r]}
# end
