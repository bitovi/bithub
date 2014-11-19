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
    @service = embed.services.build(service_definition)

    if embed.save
      render 'api/v3/services/show'
    else
      render :json => msg_hash(@service, 'create'), :status => 406
    end
  end

  def tree
    if !test_acc?
      @tree = Hash[ brands_with_nested_service_pairs ]
      render json: @tree
    else
      render json: JSON.parse(File.read('config/test_account.json'))
    end
  end

  def suggestions
    bi = current_brand.identities.find_by_provider(params[:feed_name])
    render json: Identities::SuggestionNormalizer.new(bi).normalize(params[:type_name])
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
      render :json => msg_hash(@service, 'destroy'), :status => 406
    end
  end

  private

  def brands_with_nested_service_pairs
    Brand.all.map do |b|
      [b.name, Hash[ feed_name_config_pairs ]]
    end
  end

  def feed_name_config_pairs
    Service.all do |s|
      !s.config.data.present?
    end.map do |s|
      [s.feed_name, s.config.data]
    end
  end

  def test_acc?
    !params[:test_acc].nil?
  end

  def embed_id
    params.require(:embed_id)
  end

  def service_id
    params[:service_id] || params[:id]
  end

  def service_definition
    service_kind.merge({json_config: service_config})
  end

  def service_kind
    params.require(:service).permit(:feed_name, :type_name)
  end

  def service_config
    @json ||= ActionController::Parameters.new(JSON.parse_nil(request.body.read))
    @json.require(:service).require(:config).permit!
  end
end
