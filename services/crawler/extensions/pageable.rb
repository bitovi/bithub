module Pageable

  module Disqus
    def next_page(http_req)
      if cursor = extract_cursor(http_req.response)
        if cursor['hasNext'] == true
          fetch(@endpoint, {http_query: {cursor: cursor['next']}})
        end
      end
    end

    def extract_cursor(response)
      Yajl::Parser.parse(response)['cursor']
    end
  end

  module Stackexchange
    def next_page(http_req)
      if parsed = Yajl::Parser.parse(http_req.response)
        if parsed['has_more'] == true
          next_page = parsed['page'].to_i + 1
          fetch(@endpoint, {http_query: {page: next_page}})
        end
      end
    end

    def extract_cursor(response)
      Yajl::Parser.parse(response)['cursor']
    end
  end

end
