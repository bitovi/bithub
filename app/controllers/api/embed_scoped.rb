module Api::EmbedScoped
  def owner_embed
    current_brand.embeds.find(embed_id)
  end
  
  def embed_id
    params[:embed_id]
  end
end
