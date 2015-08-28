class CleanOrphanedEntitiesJob < ApplicationJob
  def perform(tenant_name)
    Support::OrphanedEntitiesCleaner.new(tenant_name).clean
  end
end
