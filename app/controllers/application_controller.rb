class ApplicationController < ActionController::Base

  rescue_from ActionController::RoutingError, with: :render_404
  rescue_from ActionView::MissingTemplate, with: :render_404

  def render_404
    render "frontend/404", layout: false
  end
end
