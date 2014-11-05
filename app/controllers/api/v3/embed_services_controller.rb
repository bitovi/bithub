class Api::V3::EmbedServicesController < Api::V3::BaseController
  include Api::V3::Helpers::EmbedServiceFilterParams

  before_filter :authenticate!
  # load_and_authorize_resource

  def index
    embed = current_brand.embeds.find(embed_id)
    @services = embed.services
    render 'api/v3/services/index'
  end

  def show
    embed = current_brand.embeds.find(embed_id)
    @service = embed.services.find(service_id)
    render 'api/v3/services/show'
  end

  def create
    embed = current_brand.embeds.find(embed_id)
    @service = embed.services.build(merged_params)

    if embed.save
      render 'api/v3/services/show'
    else
      render :json => msg_hash(@service, 'create'), :status => 406
    end
  end

  def update
    # TODO
  end

  def destroy
    embed = current_brand.embeds.find(embed_id)
    @service = embed.services.find(service_id)

    if @service.destroy
      render :json => msg_hash(@service, 'destroy', 'success')
    else
      render :json => msg_hash(@config, 'destroy'), :status => 406
    end
  end

  private
  def embed_id
    params.require(:embed_id)
  end

  def service_id
    params[:service_id] || params[:id]
  end

  def merged_params
    service_params.merge({json_config: json_config})
  end

  def service_params
    params.require(:service).permit(:feed_name)
  end

  def json_config
    @json ||= ActionController::Parameters.new(JSON.parse_nil(request.body.read))
    @json.require(:service).require(:json_config).permit!
  end
end
