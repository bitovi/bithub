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

  def render_404
    render "frontend/404", status: 404, layout: false
  end

  def render_401
    render text: "401 Forbidden", status: 401
  end
end
