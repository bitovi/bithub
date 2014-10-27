class Api::V3::ServicesController < Api::V3::BaseController
  before_filter :authenticate!

  # CanCan vs Rails4 bug, see:
  # https://github.com/ryanb/cancan/issues/835#issuecomment-21321676

  load_and_authorize_resource except: [:tree]

  def index
    @services = current_brand.services.all
    render :index
  end

  def show
    @config = current_brand.services.find_by_id actual_params[:id]
    render :show
  end

  def create
    @service = Service.new(service_params)

    if @service.save
      render :show
    else
      render :json => msg_hash(@config, 'create'), :status => 406
    end
  end

  def destroy
    @service = Service.find(params[:id])

    if @service.destroy
      render :json => { 'msg' => 'destroyed' }
    else
      render :json => msg_hash(@config, 'create'), :status => 406
    end
  end

  def service_params
    params.require(:service).permit(:name, :embed_id, :feed_name)
  end

end
