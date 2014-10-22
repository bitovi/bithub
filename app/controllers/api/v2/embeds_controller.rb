class Api::V2::EmbedsController < Api::V2::BaseController
  before_filter :authenticate!

  def index
    @embeds = current_brand.embeds.all
    render :index
  end
  
  def show
    @embed = current_brand.embeds.where(id: params[:id]).first
    render :show
  end

  def create
  end

  def update
  end

  def destroy
  end
end
