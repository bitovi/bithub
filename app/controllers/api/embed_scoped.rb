module Api::EmbedScoped
  def owner_embed
    Embed.find(embed_id)
  end
  
  def embed_id
    params[:embed_id]
  end
end
