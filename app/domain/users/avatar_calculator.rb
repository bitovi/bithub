module Users
  class AvatarCalculator
    DefaultUrl = '/assets/images/icon-user.png'
    ImageAttributes = %w(image avatar_url profile_image_url)

    def initialize(user)
      @user = user
    end

    def execute
      maybe_gravatar || maybe_source_data || DefaultUrl
    end

    def maybe_source_data
      @user.identities.order("provider asc").map do |ident|
        ImageAttributes.map do |attr|
          ident.andand['source_data'].andand[attr]
        end.compact
      end.flatten.first 
    end

    def maybe_gravatar
      if @user.email.present?
        gravatar = "http://gravatar.com/avatar/#{Digest::MD5.hexdigest(@user.email)}"

        # skip making HTTP request in tests
        return gravatar if Rails.env == "test"

        begin
          response = Net::HTTP.get_response(URI.parse(gravatar + '?d=404'))
          response.code == '200' ? gravatar : nil
        rescue
          return nil
        end
      else
        nil
      end
    end

  end
end
