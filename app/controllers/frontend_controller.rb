class FrontendController < ApplicationController

  layout :determine_layout
  helper_method :static_pages

  def render_page

    template = (params[:page] || "").gsub(/[^a-z_]+/, '')

    @current_page_title = static_pages[params[:page].to_sym]

    respond_to do |format|
      format.html { render "frontend/#{template}" }
      format.any  { head :not_found }
    end
  end

  private

    def determine_layout
      return "frontpage" if action_name == "index"
      return "pricing" if params[:page] === "pricing"
      return "application" if static_pages.keys.include?(params[:page].to_sym)
    end

    def static_pages 
      @static_pages ||= {
        terms_of_service: 'Terms of Service',
        privacy_policy: 'Privacy Policy',
        bugs: 'Report a Bug',
        about: 'About BitHub'
      }
    end

end
