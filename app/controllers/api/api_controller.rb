class Api::ApiController < ActionController::Base
  include Api::Helpers::Common

  before_filter :require_user!, except: %w(api_id)

  rescue_from ActiveRecord::RecordNotFound, with: :show_404
  rescue_from ActiveRecord::RecordInvalid, with: :show_406
  rescue_from CanCan::AccessDenied, with: :show_403
  
  def require_user!
    show_401("You're not authorized to access this resource.") unless user_signed_in?
  end

  def api_id
    respond_to do |format|
      format.text { render plain: 'Bithub API' }
      format.json { render json: { message: 'Bithub API' }}
    end
  end

  # deals with http://factore.ca/blog/258-rails-4-strong-parameters-and-cancan
  before_filter do
    resource = controller_path.split('/').last.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  # CanCan override:
  # https://github.com/ryanb/cancan/wiki/changing-defaults
  def current_ability
    if user_signed_in?
      @current_ability ||= UserAbility.new current_user
    else
      @current_ability ||= AnonAbility.new
    end
  end

  def current_brand
    Brand.find_by_tenant_name(session['tenant_name'])
  end
  
  def current_organization
    Organization.find_by_id(session['organization_id'])
  end
end
