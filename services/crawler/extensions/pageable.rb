module Pageable
  module Github
    def next_page(http_req)
      if (link_header = http_req.response_header['LINK'])
        if (next_page_url = link_by_type(link_header, 'next').andand[:url])
          fetch(next_page_url)
        end
      end
    end

    def link_by_type(link_header, type)
      parse_link_header(link_header).select{|l| l[:type] == type}.first
    end

    def parse_link_header(lh)
      # TODO select only links that have 'rel' attr
      lh.split(',').map do |rel|
        with_rel_attrs = pluck_pagination(rel)
        Hash[[:whole, :url, :type].zip with_rel_attrs]
      end
    end

    def pluck_pagination(rel)
      (rel.match /<(.*)>; rel="(.*)"/).to_a
    end
  end

  module Disqus
    def next_page(http_req)
      if cursor = extract_cursor(http_req.response)
        if cursor['hasNext'] == true
          next_page_url = @endpoint + "?cursor=" + cursor['next']
          fetch(next_page_url)
        end
      end
    end

    def extract_cursor(response)
      Yajl::Parser.parse(response)['cursor']
    end
  end
end
