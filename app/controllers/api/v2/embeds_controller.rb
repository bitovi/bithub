class Api::V2::EmbedsController < Api::V2::BaseController
  before_filter :authenticate!

  def index
    @embeds = current_account.brand.embeds
    render :index
  end

  def show
    @config = current_account.brand.embeds.find_by_id(params[:id])
    render :show
  end

end
