module DeviseHelper
  def devise_error_messages!
    flash_alerts = []

    css_class = 'info'

    if !flash.empty?
      flash_alerts.push(flash[:error]) if flash[:error]
      flash_alerts.push(flash[:alert]) if flash[:alert]
      flash_alerts.push(flash[:notice]) if flash[:notice]
    end

    css_class = 'danger' if flash && (flash[:error] || flash[:alert])

    return "" if resource.errors.empty? && flash_alerts.empty?

    errors = resource.errors.empty? ? flash_alerts : resource.errors.full_messages

    messages = errors.map { |msg| content_tag(:li, msg) }.join

    html = <<-HTML
      <div class="alert alert-#{css_class}">
        <ul class="list-unstyled">#{messages}</ul>
      </div>
    HTML

    html.html_safe
  end

    def devise_error_messages?
      devise_error_messages.blank? ? false : true
    end

end
