#!/usr/bin/env ruby

app_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
require "#{app_root}/config/environment"
require "#{app_root}/users_migrator/user_mongo"

# Logging
$log = Log4r::Logger.new('users_migrator')
$log.add(Log4r::StdoutOutputter.new('console', {
  :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
}))

# Mongo connection
Mongoid.load!("config/mongoid.yml")

# iter all events
#UserMongo.all.each do |user|
#end

user = UserMongo.where(email: 'veljko@kset.org').first
puts "#{user.email}"


