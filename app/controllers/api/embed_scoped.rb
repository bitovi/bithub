module Api::EmbedScoped
  def owner_embed
    @embed = Embed.find(embed_id)
  end
  
  def embed_id
    params[:embed_id]
  end
end
