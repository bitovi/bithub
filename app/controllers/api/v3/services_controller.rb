class Api::V3::ServicesController < Api::V3::BaseController
  include Api::EmbedScoped

  # before_filter :authenticate_account!, :except => [:tree]
  # before_filter :create_new_service, only: [:create]
  # load_and_authorize_resource except: [:tree]

  def index
    if params[:embed_id]
      @services = owner_embed.services
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
    @service = owner_embed.services.build(service_definition)
    @service.humanize

    if @embed.save
      render 'api/v3/services/show'
    else
      render :json => msg_hash(@service, 'create'), :status => 406
    end
  end

  def update
    @service = Service.find_by_id(service_id)
    @service.assign_attributes(service_definition)
    @service.service_errors.destroy_all
    @service.humanize

    if @service.save
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
    raise CanCan::AccessDenied unless params['secret'] == ENV['CRAWLER_SECRET_KEY']

    big_hash = Hash[
      :brands, Brand.all.map do |b|
        Apartment::Tenant.switch b.name do
          Hash[
            :id, b.id,
            :name, b.name,
            :embeds, b.embeds.map do |e|
              Hash[
                :id, e.id,
                :name, e.name,
                :services, e.services.map do |s|
                  Hash[
                    :id, s.id,
                    :feed_name, s.feed_name,
                    :type_name, s.type_name,
                    :config, s.service_config.data.merge(s.credentials(s.config['id']))
                  ]
                end
              ]
            end
          ]
        end
      end
    ]

    render :json => big_hash.to_json
  end

  def suggestions
    if feed_name = params[:feed_name]

      if bi = current_brand.identities.find_by_provider(feed_name)
        suggestion = bi.config.suggestions params[:feed_type]
      else
        suggestion = []
      end

      render json: suggestion
    else
      render json: msg_hash(@bi, 'suggestions'), status => 406
    end
  end

  private

  def embed_id
    params[:embed_id] || params[:service].andand[:embed_id]
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

  def create_new_service
    embed = current_brand.embeds.find(embed_id)
    @service = embed.services.build(service_definition)
  end
end
