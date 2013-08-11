class Api::ApiController < ActionController::Base

  def home
    render :text => "Bithub API v1"
  end
  
  def show_401(exception)
    render json: { message: exception.message }, status: 401
  end

  def show_404(exception)
    render json: exception, status: 404
  end

  def show_406(exception)
    render json: exception, status: 406
  end
  
  def msg_hash(ar_obj, t_action, t_outcome = "error")
      resp_hash = {}; t_key = ar_obj.class.to_s.downcase + "s"
      resp_hash[:message] = t("api.#{t_key}.#{t_action}.#{t_outcome}")
      resp_hash[:errors] = ar_obj.errors.full_messages if !ar_obj.errors.blank?
      resp_hash
  end
end
