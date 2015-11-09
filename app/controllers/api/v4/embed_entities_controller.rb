require 'digest/md5'

class Api::V4::EmbedEntitiesController < Api::V3::EmbedEntitiesController
  include Api::EmbedScoped
  
  def index
    super do
      Apartment::Tenant.switch(@tenant_name) do
        scope = build_scope
        @entities = EntityDecorator.decorate_collection(scope.all, context: { embed: owner_embed })
        render 'api/v4/embed_entities/index'
      end
    end
  end

  def decide
    if @relation = embed_entity_relation!
      authorize! :decide, @relation
      if @relation.decide(decision)
        decorate_entity
        render :show
      end
    end
  end

  private

  def decision
    params[:decision] || 'pending'
  end
end
