class Api::V3::BaseController < ActionController::Base
  include Helpers::Common

  # deals with http://factore.ca/blog/258-rails-4-strong-parameters-and-cancan
  before_filter do
    resource = controller_path.split('/').last.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  rescue_from ActiveRecord::RecordNotFound, with: :show_404
  rescue_from ActiveRecord::RecordInvalid, with: :show_406
  rescue_from CanCan::AccessDenied, with: :show_403

  respond_to :json

  def home
    render :text => "Bithub API v3", content_type: "text/plain"
  end

  # CanCan override:
  # https://github.com/ryanb/cancan/wiki/changing-defaults
  def current_ability
    if account_signed_in?
      @current_ability ||= AccountAbility.new current_account
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
