FactoryGirl.define do
  factory :embed do
    sequence :name do |n|
      "Embed that embeds Internet no #{n}"
    end
    colorscheme 'peaksea'
    layout 'up and down'

    before(:create) do |embed|
      embed.class.skip_callback(:create, :after, :notify_embed_start)
      embed.class.skip_callback(:update, :after, :notify_embed_restart)
      embed.class.skip_callback(:destroy, :after, :notify_embed_stop)
    end
  end
end
