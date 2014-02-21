module Events
  module Github
    module Accessors

      module IssueLike

        def title
          (@i || @pr).andand[:title]
        end

        def body
          (@i || @pr).andand[:body]
        end

        def html_url
          (@i || @pr).andand[:html_url]
        end

        def number
          (@i || @pr).andand[:number]
        end

        def state
          (@i || @pr).andand[:state]
        end

        def action
          (@i || @pr).andand[:action]
        end

      end

    end
  end
end
