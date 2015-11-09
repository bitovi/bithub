class Api::V4::ApiController < Api::ApiController
  def api_id
    respond_to do |format|
      format.text { render plain: 'Bithub API v4' }
      format.json { render json: { message: 'Bithub API v4' }}
    end
  end
end
