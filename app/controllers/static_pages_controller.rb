class StaticPagesController < ApplicationController

  layout :determine_layout
  helper_method :static_pages

  def render_page
    template = (params[:page] || "").gsub(/[^a-z_]+/, '')

    if template_exists? "static_pages/#{params[:page]}"
      @current_page_title = static_page_titles[params[:page].to_sym]

      respond_to do |format|
        format.html { render "static_pages/#{template}" }
        format.any  { head :not_found }
      end
    else
      render_404
    end
  end

  private

  def determine_layout
    return "frontpage" if action_name == "index"
    return "application"
  end

  def static_page_titles
    @static_pages ||= {
      terms_of_service: 'Terms of Service',
      privacy_policy: 'Privacy Policy'
    }
  end

end
