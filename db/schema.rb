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

ActiveRecord::Schema.define(:version => 20130226190900) do

  create_table "activities", :force => true do |t|
    t.integer  "applies_to_event_id"
    t.integer  "actor_id"
    t.string   "type"
    t.integer  "points"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "countries", :force => true do |t|
    t.string "name"
    t.string "display_name"
    t.string "iso"
  end

  create_table "events", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.string   "url"
    t.string   "hash_key"
    t.string   "feed"
    t.string   "type"
    t.string   "state"
    t.string   "label"
    t.integer  "author_id"
    t.integer  "rule_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "events_tags", :force => true do |t|
    t.integer "event_id"
    t.integer "tag_id"
  end

  create_table "roles", :force => true do |t|
    t.integer  "level"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "rules", :force => true do |t|
    t.string   "feed"
    t.string   "type"
    t.string   "state"
    t.string   "label"
    t.string   "catgory"
    t.integer  "points"
    t.integer  "award"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.string   "display_name"
    t.integer  "count"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "address"
    t.string   "city"
    t.string   "postal"
    t.string   "state"
    t.integer  "country_id"
    t.integer  "role_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
