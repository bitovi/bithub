module EventProcessor
  module Commons 
    def feed
      @feed ||= self.class.to_s.gsub('EventProcessor::','').snake_case
    end

    # Twitter date format: "Tue Jan 29 20:55:35 +0000 2013" -> "%a %b %d %T %z %Y"
    # Github  date format: "2013-02-14T22:47:29Z"
    def parse_date(date_str)
      date_str ? Time.parse(date_str).utc : Time.now.utc
    end
  end
end
