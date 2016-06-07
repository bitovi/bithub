module Api::Helpers
	module Common
		def show_400(reason)
			render_status_code(reason, :bad_request)
		end
		
		def show_401(reason)
			render_status_code(reason, :unauthorized)
		end
    
		def show_403(reason)
			render_status_code(reason, :forbidden)
		end

		def show_404(reason)
			render_status_code(reason, :not_found)
		end
    
		def show_406(reason)
			render_status_code(reason, :not_acceptable)
		end

		def show_422(reason)
			render_status_code(reason, :unprocessable_entity)
		end

		def render_status_code(reason, status)
			message = reason.respond_to?(:message) ? reason.message : reason
			return respond_to do |format|
				format.json { render json: { message: message }, status: status }
				format.html { render html: message.html_safe, status: status }
				format.text { render plain: message, status: status }
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
