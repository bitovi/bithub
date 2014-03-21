class Api::V2::FeedConfigsController < Api::V2::BaseController
  #load_and_authorize_resource
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :show_404
  rescue_from ActiveRecord::RecordInvalid, with: :show_406

  def index
    @configs = FeedConfig.all
    render :index
  end

  def show
    @config = FeedConfig.find(params[:id])
    render :show
  end

  def create
    @config = FeedConfig.new(config_params)

    if @config.save
      render show
    else
      render :json => msg_hash(@config, 'create'), :status => 406
    end
  end

  def update
    @config = FeedConfig.find(params[:id])

    if @config.update_attributes(config_params)
      render :show
    else
      render :json => msg_hash(@config, 'update'), :status => 406
    end
  end

  def destroy
    @config = FeedConfig.find(params[:id])

    if @config.destroy
      render :json => msg_hash(@config, 'destroy', 'success')
    else
      render :json => msg_hash(@config, 'destroy'), :status => 406
    end
  end

  private

  def config_params
    params.require(:feed_config).permit(:feed_name, :config)
  end

end
