class Api::V3::EmbedsController < Api::V3::ApiController
  include Api::EmbedScoped

  def index
    authorize! :index, Embed

    scope = scope_applier\
      .apply_muster_query_to_scope(muster_query)\
      .apply_order_to_scope
      .result

    @embeds = scope.all
  end

  def show
    if (tn = (params[:tenant_name] || Apartment::Tenant.current))
      tn = nil unless Apartment.tenant_names.include?(tn)
      Apartment::Tenant.switch(tn) do
        authorize! :show, owner_embed
        render :show
      end
    end
  end

  def create
    authorize! :create, built_embed

    @embed.name = generated_name if params[:name].blank?

    if @embed.save
      render :show
    else
      render :json => msg_hash(@embed, 'create'), :status => 422
    end
  end

  def update
    authorize! :update, owner_embed

    if @embed.update_attributes(embed_params)
      render :show
    end
  end

  def destroy
    authorize! :destroy, owner_embed

    if @embed.destroy
      CleanOrphanedEntitiesJob.perform_later(Apartment::Tenant.current)

      render :json => msg_hash(@embed, 'destroy', 'success'), :status => 204
    else
      render :json => msg_hash(@embed, 'destroy'), :status => 406
    end
  end

  def moderate
    authorize! :moderate, owner_embed

    if @embed.moderate
      render :json => msg_hash(@embed, 'moderate')
    else
      render :json => msg_hash(@embed, 'moderate', 'error')
    end
  end

  def publish
    authorize! :update, owner_embed

    if current_organization.subscription.chargeable?
      @embed.update_attribute :published, true
      render :show
    else
      render :json => msg_hash(@embed, 'publish', 'payment_required'), :status => 402
    end
  end

  def unpublish
    authorize! :update, owner_embed

    if @embed.update_attribute :published, false
      render :show
    end
  end

  private

  def built_embed
    @embed = current_brand.embeds.build(embed_params)
  end

  def embed_params
    params.require(:embed).permit(:name, :colorscheme, :layout, :approved_by_default)
  end
  
  def scope_applier(current_scope = nil)
    ScopeApplier.new((current_scope || Embed), QueryLogic::Query.new(Embed, params))
  end

  def generated_name
    Bazaar.heroku
  end

  def embed_id
    params[:id]
  end
end
