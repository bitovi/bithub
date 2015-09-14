module Api::Helpers
  module Common

    def show_401(reason = nil)
      message = reason.respond_to?(:message) ? reason.message : reason
      render_by_format(message, :unauthorized)
    end
    
    def show_403(reason)
      message = reason.respond_to?(:message) ? reason.message : reason
      render_by_format(message, :forbidden)
    end

    def show_404(reason)
      message = reason.respond_to?(:message) ? reason.message : reason
      render_by_format(message, :not_found)
    end
    
    def show_406(reason)
      message = reason.respond_to?(:message) ? reason.message : reason
      render_by_format(message, :not_acceptable)
    end

    def render_by_format(message, status_sym)
      respond_to do |format|
        format.json { render json: { message: message }, status: status_sym }
        format.html { render html: message.html_safe, status: status_sym }
        format.text { render plain: message, status: status_sym }
      end
    end

    def muster_query
      request.env['muster.query']
    end

    def msg_hash(obj, t_action, t_outcome = "error")
      t_key = determine_key_type(obj)

      resp_hash = {
        message: t("api.#{t_key}.#{t_action}.#{t_outcome}")
      };

      if is_ar_object?(obj) && !obj.errors.blank?
        resp_hash[:errors] = obj.errors
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
      Apartment::Tenant.current
    end
  end
end
