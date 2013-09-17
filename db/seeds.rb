# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

projects = YAML::load_file('config/tag_aliases.yml')
categories = YAML::load_file('config/categories.yml')
projects.each {|t, opts| Tag.create({name: t, display_name: opts['display_name'], aliases: opts['aliases']}) }
categories.each {|c, opts| Tag.create({name: c, display_name: opts['display_name']}) }
