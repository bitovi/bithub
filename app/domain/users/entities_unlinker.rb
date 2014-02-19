module Users
  class EntitiesUnlinker

    class UnlinkingJob < Struct.new(:uid)
      def perform
        if (ident = Identity.find_by_uid(uid))
          EntitiesUnlinker.new(ident).unlink
        end
      end
    end

    def initialize(ident)
      @ident = ident
    end

    def unlink
      unlink_internals
      unlink_entities
      @ident.destroy
    end
    
    def async_unlink
      Delayed::Job.enqueue UnlinkingJob.new(@ident.uid)
    end

    def unlink_entities
      Entity.origin_author(@ident.uid).find_each do |e|
        e.ownerships
        .where(ownership_type: 'author')
        .where(owner: @ident.user)
        .destroy_all
      end
    end

    def unlink_internals
      if @ident.user && @ident.user.internals
        @ident.user.internals.where(variant: "linked_#{@ident.provider}").destroy_all
      end
    end
  end
end
