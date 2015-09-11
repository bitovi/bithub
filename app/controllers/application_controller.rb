class ApplicationController < ActionController::Base
  rescue_from ActionController::RoutingError, with: :render_404
  rescue_from ActionView::MissingTemplate, with: :render_404
  rescue_from CanCan::AccessDenied, with: :render_401

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
    Organization.find(session['organization_id'])
  end

  def render_404
    render "static_pages/404", status: 404, layout: false
  end

  def render_401
    render text: "401 Forbidden", status: 401
  end
end
