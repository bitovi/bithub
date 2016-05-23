class Api::V3::ServicesController < Api::V3::ApiController
  include Api::HubScoped

  def index
    authorize! :index, Service
    all_services
    render 'api/v3/services/index'
  end

  def show
    authorize! :show, a_service

    if @service
      render 'api/v3/services/show'
    else
      render :json => msg_hash(@service, 'show'), :status => 404
    end
  end

  def create
    authorize! :create, built_service

    @service.credential = Credential.find_by_id(brand_idbit_id)
    @service.humanized_config

    feed_name = service_kind[:feed_name]
    type_name = service_kind[:type_name]

    if @service.save
      render 'api/v3/services/show'
    else
      render :json => msg_hash(@service, 'create'), :status => 406
    end
  end

  def update
    authorize! :update, a_service

    @service.assign_attributes(service_definition)
    @service.service_errors.destroy_all
    @service.humanized_config

    if @service.save
      render 'api/v3/services/show'
    else
      render :json => msg_hash(@service, 'create'), :status => 406
    end
  end

  def destroy
    authorize! :destroy, a_service

    if @service.clear_relations_and_destroy
      CleanOrphanedEntitiesJob.perform_later(Apartment::Tenant.current)

      render :json => msg_hash(@service, 'destroy', 'success'), :status => 204
    else
      render :json => msg_hash(@service, 'destroy'), :status => 406
    end
  end

  def suggestions
    authorize! :suggest, Service

    if feed_name = params[:feed_name]
      suggestions = []
      if params[:feed_name] == 'instagram' && (username = params[:username])
        suggestions += api_adapter.user_from_instagram(params[:username])

      # VISE IDENTITETA
      elsif bi = current_brand.identities.where(id: brand_idbit_id, provider: feed_name).first
        suggestions += bi.property_id_name_pairs(params[:feed_type])
      end

      render json: suggestions
    else
      render json: msg_hash(@bi, 'suggestions'), status => 406
    end
  end

  private

  def all_services
    @services = hub_id ? owner_hub.services : Service.all
  end

  def a_service
    @service = Service.find(service_id)
  end

  def built_service
    @service = owner_hub.services.build(service_definition)
  end

  def hub_id
    params[:hub_id] || params[:service].andand[:hub_id]
  end

  def brand_idbit_id
    params[:brand_idbit_id] || params[:service].andand[:brand_idbit_id]
  end

  def service_id
    params[:service_id] || params[:id]
  end

  def service_definition
    service_kind.merge({config: service_config})
  end

  def service_kind
    params.require(:service).permit(:feed_name, :type_name, :approved_by_default)
  end

  def service_config
    @json ||= ActionController::Parameters.new(JSON.parse_nil(request.body.read))
    @json.require(:service).require(:config).permit!
  end

  def api_adapter
    Support::ThirdPartyApiAdapter.new
  end
end
