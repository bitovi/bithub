# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130304122257) do

  create_table "activities", :force => true do |t|
    t.integer  "applies_to_id",    :null => false
    t.integer  "actor_id",         :null => false
    t.string   "type",             :null => false
    t.integer  "awarded_value"
    t.integer  "staked_value"
    t.boolean  "stake_fullfilled"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "countries", :force => true do |t|
    t.string "name",         :null => false
    t.string "display_name"
    t.string "iso",          :null => false
  end

  create_table "events", :force => true do |t|
    t.string   "hash_key",    :null => false
    t.string   "title"
    t.string   "url"
    t.text     "body"
    t.integer  "author_id"
    t.integer  "rule_id",     :null => false
    t.integer  "parent_id"
    t.integer  "feed_id",     :null => false
    t.integer  "category_id", :null => false
    t.date     "date",        :null => false
    t.hstore   "props"
    t.text     "source_data",    :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "events", ["hash_key"], :name => "index_events_on_hash_key"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "rules", :force => true do |t|
    t.string_array "required_tags",    :limit => 255
    t.integer      "authorship_value"
    t.integer      "award_value"
    t.integer      "upvote_value"
    t.integer      "priority"
    t.datetime     "created_at",                      :null => false
    t.datetime     "updated_at",                      :null => false
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string       "name"
    t.string       "display_name"
    t.string_array "aliases"
  end

  create_table "users", :force => true do |t|
    t.string   "name",                               :null => false
    t.string   "email"
    t.string   "address"
    t.string   "city"
    t.string   "postal"
    t.string   "state"
    t.integer  "country_id"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "provider"
    t.string   "uid"
  end

  add_index "users", ["email"], :name => "index_users_on_email"

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

end
