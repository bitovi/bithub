class Api::V3::ServicesController < Api::V3::ApiController
  include Api::EmbedScoped

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

    @service.brand_identity = BrandIdentity.find_by_id(brand_identity_id)
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

    feed = params[:feed_name]
    bi = current_brand.identities.where(provider: feed).first
    if feed_name = params[:feed_name]
      suggestions = []
      if feed == 'instagram' && (username = params[:username])
        suggestions += api_adapter.user_from_instagram(params[:username], bi)

      # VISE IDENTITETA
      elsif bi
        suggestions += bi.property_id_name_pairs(params[:feed_type])
      end

      render json: suggestions
    else
      render json: msg_hash(@bi, 'suggestions'), status => 406
    end
  end

  private

  def all_services
    @services = embed_id ? owner_embed.services : Service.all
  end

  def a_service
    @service = Service.find(service_id)
  end

  def built_service
    @service = owner_embed.services.build(service_definition)
  end

  def embed_id
    params[:embed_id] || params[:service].andand[:embed_id]
  end

  def brand_identity_id
    params[:brand_identity_id] || params[:service].andand[:brand_identity_id]
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
