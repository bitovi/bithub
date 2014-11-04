class Api::V3::BrandIdentitiesController < Api::V3::BaseController
  before_filter :authenticate!
  load_and_authorize_resource

  def destroy
    @bi = current_brand.identities.find(params[:id])

    if @bi.destroy
      render :json => msg_hash(@bi, 'destroy', 'success')
    else
      render :json => msg_hash(@bi, 'destroy'), :status => 406
    end
  end

end
