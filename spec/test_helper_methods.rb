# ---------------
# Tag definitions
# ---------------

def import_tags
  tags = YAML::load_file(File.join(PROJECT_ROOT, 'config', 'tag_definitions.yml'))
  tags.each do |tag_name, opts|
    t = Tag.new({
      name: tag_name,
      display_name: opts['display_name'],
      aliases: opts['aliases'],
      props: opts['props']
    })
    t.group_list = opts['group_list']
    t.save
  end
end

# ----------------
# Response loading
# ----------------

def load_and_parse(path)
  ext_name = File.extname(path).gsub('.','').to_sym

  loaders = {
    json: lambda {|p| JSON.parse(File.read(path)) },
    rss: lambda {|p| Nori.new(:parser => :nokogiri).parse(File.read(path)) }
  }

  loaders[ext_name].(path)
end

def raw_data(opts = {})
  load_and_parse File.join('spec/support/responses', opts[:response_path])
end

# ----------------
# Oauth dummy data
# ----------------
def oauth_data_hash(provider = 'github', uid = 123456789, email = 'neektza@gmail.com', name = 'Nikica Jokic')
  Hash['omniauth.auth', Hash['provider', provider, 'uid', uid, 'info', Hash['email', email, 'name', name]]]
end
