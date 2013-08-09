class Api::RewardsController < Api::ApiController
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :show_404
  rescue_from ActiveRecord::RecordInvalid, with: :show_406

  def index
    @rewards = Reward.all
    render :index
  end

  def show
    @reward = Reward.find(params[:id])
    render :show
  end

  def create
    @reward = Reward.new(params[:reward])
    if @reward.save
      render :show
    else
      render :json => msg_hash(@reward, 'create'), :status => 406
    end
  end

  def update
    @reward = Reward.find(params[:id])
    if @reward.update_attributes(params[:reward])
      render :show
    else
      render :json => msg_hash(@reward, 'update'), :status => 406
    end
  end
  
  def destroy
    @reward = Reward.find(params[:id])
    if @reward.destroy
      render :json => msg_hash(@reward, 'destroy', 'success')
    else
      render :json => msg_hash(@reward, 'destroy'), :status => 406
    end
  end

end
