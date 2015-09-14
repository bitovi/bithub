class Api::V3::ApiController < Api::ApiController
  def api_id
    respond_to do |format|
      format.text { render plain: 'Bithub API v3' }
      format.json { render json: { message: 'Bithub API v3' }}
    end
  end
end
