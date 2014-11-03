class Api::V3::ServicesController < Api::V3::BaseController
  before_filter :authenticate!
  load_and_authorize_resource

  # CanCan vs Rails4 bug, see:
  # https://github.com/ryanb/cancan/issues/835#issuecomment-21321676

  def index
    @services = current_brand.services.all
    render :index
  end

  def show
    @service = current_brand.services.find_by_id params[:id]
    render :show
  end

  def create
    @service = current_brand.services.build(merged_params)

    if @service.save
      render :show
    else
      render :json => msg_hash(@service, 'create'), :status => 406
    end
  end

  def destroy
    @service = current_brand.services.find(params[:id])

    if @service.destroy
      render :json => { 'msg' => 'destroyed' }
    else
      render :json => msg_hash(@config, 'create'), :status => 406
    end
  end

  def merged_params
    service_params.merge({json_config: json_config})
  end

  def service_params
    params.require(:service).permit(:embed_id, :feed_name)
  end

  def json_config
    @json ||= ActionController::Parameters.new(JSON.parse_nil(request.body.read))
    @json.require(:service).require(:json_config).permit!
  end

end
