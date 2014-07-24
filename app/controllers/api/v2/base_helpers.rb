module Api::V2::BaseHelpers

  def show_401(exception)
    render json: { message: exception.message }, status: 401
  end

  def show_404(exception)
    render json: exception, status: 404
  end
  
  def muster_query
    request.env['muster.query']
  end

  def show_406(exception)
    render json: exception, status: 406
  end

  def msg_hash(obj, t_action, t_outcome = "error")
    t_key = determine_key_type(obj)

    resp_hash = {
      message: t("api.#{t_key}.#{t_action}.#{t_outcome}")
    };

    if is_ar_object?(obj) && !obj.errors.blank?
      resp_hash[:errors] = obj.errors.full_messages if !obj.errors.blank?
    end

    resp_hash
  end

  private

  def determine_key_type(obj)
    # leave string or symbol as is
    if obj.kind_of?(String) || obj.kind_of?(Symbol)
      obj.to_s.downcase + 's'
    # for instance use class name
    elsif !obj.kind_of?(Class)
      obj.class.to_s.downcase + 's'
    # otherwise ...
    else
      obj.to_s.downcase + 's'
    end
  end

  def is_ar_object?(obj)
    obj.kind_of? ActiveRecord::Base
  end

  def current_brand
    Apartment::Database.current_tenant
  end

end
