require 'wrappers/data_accessible'

module Wrappers
  module Tumblr

    class Post
      include DataAccessible
      include CoreHelpers

      # text, photo, quote, link, chat, audio, video, answer -> one per line in 'maybe_has'

      has :id, :blog_name, :post_url, :type, :timestamp, :tags, :source_url, :source_title
      maybe_has :title, :body, \
                :photos, :caption, :width, :height, \
                :text, :source, \
                :title, :url, :description, \
                :title, :body, :dialogue, \
                :caption, :player, :album_art, :artist, :album, :track_name, :track_number, :year, \
                :caption, :player, \
                :asking_name, :asking_url, :question, :answer

      def initialize(post)
        @data = symbolize_keys(post)
      end

    end
  end
end
