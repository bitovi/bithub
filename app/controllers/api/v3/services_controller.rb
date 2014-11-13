class Api::V3::ServicesController < Api::V3::BaseController
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

    if @service
      render 'api/v3/services/show'
    else
      render :json => msg_hash(@service, 'show'), :status => 404
    end
  end

  def create
    embed = current_brand.embeds.find(embed_id)
    @service = embed.services.build(service_params)

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
    @service.build_filter

    if @service.destroy
      render :json => msg_hash(@service, 'destroy', 'success')
    else
      render :json => msg_hash(@service, 'destroy'), :status => 406
    end
  end

  private

  def embed_id
    params.require(:embed_id)
  end

  def service_id
    params[:service_id] || params[:id]
  end

  def service_params
    feed_name.merge({json_config: service_config})
  end

  def feed_name
    params.require(:service).permit(:feed_name, :type_name)
  end

  def service_config
    @json ||= ActionController::Parameters.new(JSON.parse_nil(request.body.read))
    @json.require(:service).require(:config).permit!
  end
end
