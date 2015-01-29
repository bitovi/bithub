class Api::V3::BrandIdentitiesController < Api::V3::BaseController
  before_filter :authenticate_account!
  load_and_authorize_resource

  def show
    if @identity = current_brand.identities.find(params[:id])
      render :show
    else
      render :json => msg_hash(@identity, 'show'), status: 406
    end
  end

  def index
    @identities = current_brand.identities || []
    render :index
  end

  def destroy
    @bi = current_brand.identities.find(params[:id])

    if @bi.destroy
      render :json => msg_hash(@bi, 'destroy', 'success')
    else
      render :json => msg_hash(@bi, 'destroy'), :status => 406
    end
  end

end
