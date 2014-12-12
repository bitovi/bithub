class Api::V3::ServicesController < Api::V3::BaseController
  before_filter :authenticate!, :except => [:tree]
  # load_and_authorize_resource

  def index
    if params[:embed_id]
      embed = current_brand.embeds.find params[:embed_id]
      @services = embed.services
    else
      @services = Service.all
    end

    render 'api/v3/services/index'
  end

  def show
    if @service = Service.find(service_id)
      render 'api/v3/services/show'
    else
      render :json => msg_hash(@service, 'show'), :status => 404
    end
  end

  def create
    embed = current_brand.embeds.find(embed_id)
    @service = embed.services.build(service_definition)

    if embed.save
      render 'api/v3/services/show'
    else
      render :json => msg_hash(@service, 'create'), :status => 406
    end
  end

  def destroy
    @service = Service.find(service_id)

    if @service && @service.destroy
      render :json => msg_hash(@service, 'destroy', 'success')
    else
      render :json => msg_hash(@service, 'destroy'), :status => 406
    end
  end

  def tree
    @brands = Brand.all
    render 'api/v3/services/tree'
  end

  def suggestions
    bi = current_brand.identities.find_by_provider(params[:feed_name])
    render json: Identities::SuggestionNormalizer.new(bi).normalize(params[:type_name])
  end

  private

  def embed_id
    params[:embed_id] || params.require(:service).require(:embed_id)
  end

  def service_id
    params[:service_id] || params[:id]
  end

  def service_definition
    service_kind.merge({config: service_config})
  end

  def service_kind
    params.require(:service).permit(:feed_name, :type_name)
  end

  def service_config
    @json ||= ActionController::Parameters.new(JSON.parse_nil(request.body.read))
    @json.require(:service).require(:config).permit!
  end
end
