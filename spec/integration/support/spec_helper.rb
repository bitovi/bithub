require 'lib/api_wrappers/github'
require 'lib/api_wrappers/bithub'
require 'yaml'
require 'git'

module Helpers

  def Helpers.load_config(path=nil)
    path = './spec/integration_testing/config.yml' unless  path
    YAML::load_file(path)    
  end
  
  def Helpers.unique_string(length=6, set=nil)
    set = [*(0..9), *('a'..'z'), *('A'..'Z')] unless set
    (0..length).map {|_| set[rand(set.length)].to_s }.join
  end

  def Helpers.git_create_push(repo_path, commit_msg, files=[], logger=nil)
    g = Git.open(repo_path, :log => logger)

    files.each do |filename|
      File.open(File.join(repo_path, filename),'a+') do
        |f| f.puts [Time.now.to_s, commit_msg, "Appending new line ..."].join(" ")
      end
    end

    g.add(:all => true)
    g.commit_all(commit_msg)
    g.push
  end

  def Helpers.git_clone(uri, path, opts={})
    return if File.exists?(path)
    
    g = Git.clone(uri, path)
    opts[:username] && g.config('user.name', opts[:username])
    opts[:email] && g.config('user.email', opts[:email])
  end
end
