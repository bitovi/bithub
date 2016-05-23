class Api::V3::HubsController < Api::V3::ApiController
  include Api::HubScoped

  def index
    authorize! :index, Hub

    scope = scope_applier\
      .apply_muster_query_to_scope(muster_query)\
      .apply_order_to_scope
      .result

    @hubs = scope.all
  end

  def show
    if (tn = (params[:tenant_name] || Apartment::Tenant.current))
      tn = nil unless Apartment.tenant_names.include?(tn)
      Apartment::Tenant.switch(tn) do
        authorize! :show, owner_hub
        render :show
      end
    end
  end

  def create
    authorize! :create, built_hub

    @hub.name = generated_name if params[:name].blank?

    if @hub.save
      render :show
    else
      render :json => msg_hash(@hub, 'create'), :status => 422
    end
  end

  def update
    authorize! :update, owner_hub

    if @hub.update_attributes(hub_params)
      render :show
    end
  end

  def destroy
    authorize! :destroy, owner_hub

    if @hub.destroy
      CleanOrphanedEntitiesJob.perform_later(Apartment::Tenant.current)

      render :json => msg_hash(@hub, 'destroy', 'success'), :status => 204
    else
      render :json => msg_hash(@hub, 'destroy'), :status => 406
    end
  end

  def moderate
    authorize! :moderate, owner_hub

    if @hub.moderate
      render :json => msg_hash(@hub, 'moderate')
    else
      render :json => msg_hash(@hub, 'moderate', 'error')
    end
  end

  def publish
    authorize! :update, owner_hub

    if current_organization.subscription.chargeable?
      @hub.update_attribute :published, true
      render :show
    else
      render :json => msg_hash(@hub, 'publish', 'payment_required'), :status => 402
    end
  end

  def unpublish
    authorize! :update, owner_hub

    if @hub.update_attribute :published, false
      render :show
    end
  end

  private

  def built_hub
    @hub = current_brand.hubs.build(hub_params)
  end

  def hub_params
    params.require(:hub).permit(:name, :colorscheme, :layout, :approved_by_default)
  end
  
  def scope_applier(current_scope = nil)
    ScopeApplier.new((current_scope || Hub), QueryLogic::Query.new(Hub, params))
  end

  def generated_name
    Bazaar.heroku
  end

  def hub_id
    params[:id]
  end
end
