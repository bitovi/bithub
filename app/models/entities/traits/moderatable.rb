module Moderatable

  def moderate_and_link

    Embed.all.each do |e|

      if not(e.blocking_filter.blocks? self)
        link = e.make_link_to self

        if e.moderating_filter.approves? self
          link.approve
        end
      end

    end
  end
end
