FactoryGirl.define do
  factory :embed do
    name "Embed that embeds"
    colorscheme "peaksea"
    layout "up and down"

    before(:create) do |embed|
      embed.class.skip_callback(:create, :after, :notify_embed_start)
      embed.class.skip_callback(:update, :after, :notify_embed_restart)
      embed.class.skip_callback(:destroy, :after, :notify_embed_stop)
    end
  end
end
