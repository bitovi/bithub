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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141007111224) do


  create_extension "hstore", :version => "1.2"
  create_extension "intarray", :version => "1.0"

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "intarray"

  create_table "account_roles", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "account_roles", ["name", "resource_type", "resource_id"], :name => "index_account_roles_on_name_and_resource_type_and_resource_id"
  add_index "account_roles", ["name"], :name => "index_account_roles_on_name"

  create_table "accounts", force: true do |t|
    t.string   "name"
    t.hstore   "props",                  default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
  end

  add_index "accounts", ["email"], :name => "index_accounts_on_email", :unique => true
  add_index "accounts", ["reset_password_token"], :name => "index_accounts_on_reset_password_token", :unique => true

  create_table "accounts_account_roles", id: false, force: true do |t|
    t.integer "account_id"
    t.integer "account_role_id"
  end

  add_index "accounts_account_roles", ["account_id", "account_role_id"], :name => "index_accounts_account_roles_on_account_id_and_account_role_id"

  create_table "accounts_brands", id: false, force: true do |t|
    t.integer "brand_id",   null: false
    t.integer "account_id", null: false
  end

  add_index "accounts_brands", ["account_id", "brand_id"], :name => "index_accounts_brands_on_account_id_and_brand_id"
  add_index "accounts_brands", ["account_id"], :name => "index_accounts_brands_on_account_id"
  add_index "accounts_brands", ["brand_id", "account_id"], :name => "index_accounts_brands_on_brand_id_and_account_id"
  add_index "accounts_brands", ["brand_id"], :name => "index_accounts_brands_on_brand_id"

  create_table "achievements", force: true do |t|
    t.integer  "user_id",     null: false
    t.integer  "reward_id",   null: false
    t.string   "note"
    t.datetime "achieved_at"
    t.datetime "shipped_at"
  end

  add_index "achievements", ["reward_id"], :name => "index_achievements_on_reward_id"
  add_index "achievements", ["user_id"], :name => "index_achievements_on_user_id"

  create_table "api_cache", force: true do |t|
    t.string "provider"
    t.string "name"
    t.string "uid"
  end

  add_index "api_cache", ["uid", "provider"], :name => "index_api_cache_on_uid_and_provider"

  create_table "awards", force: true do |t|
    t.integer  "applies_to_id", null: false
    t.integer  "actor_id",      null: false
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "awards", ["actor_id"], :name => "index_awards_on_actor_id"
  add_index "awards", ["applies_to_id"], :name => "index_awards_on_applies_to_id"

  create_table "brand_identities", force: true do |t|
    t.string   "provider"
    t.string   "uid"
    t.json     "source_data", default: {}
    t.integer  "brand_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "brand_identities", ["brand_id"], :name => "index_brand_identities_on_brand_id"

  create_table "brands", force: true do |t|
    t.string   "name"
    t.string   "tenant_name"
    t.hstore   "props",       default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "brands", ["name"], :name => "index_brands_on_name", :unique => true
  add_index "brands", ["tenant_name"], :name => "index_brands_on_tenant_name", :unique => true

  create_table "brands_users", force: true do |t|
    t.integer "user_id"
    t.integer "brand_id"
    t.integer "total_score", default: 0
    t.hstore  "props",       default: {}
  end

  add_index "brands_users", ["brand_id"], :name => "index_brands_users_on_brand_id"
  add_index "brands_users", ["user_id"], :name => "index_brands_users_on_user_id"

  create_table "countries", force: true do |t|
    t.string  "name",                     null: false
    t.string  "display_name"
    t.string  "iso",                      null: false
    t.integer "priority",     default: 0
  end

  create_table "embed_entities", force: true do |t|
    t.integer "embed_id"
    t.integer "entity_id"
    t.boolean "is_approved"
  end

  create_table "embeds", force: true do |t|
    t.string  "name"
    t.string  "colorscheme"
    t.string  "layout"
    t.integer "brand_id"
  end

  add_index "embeds", ["brand_id"], :name => "index_embeds_on_brand_id"

  create_table "entities", force: true do |t|
    t.text     "title"
    t.text     "url"
    t.text     "body"
    t.string   "origin_id"
    t.string   "feed_name"
    t.string   "type_name"
    t.integer  "scoring_rule_id",                null: false
    t.integer  "parent_id"
    t.datetime "origin_ts",                      null: false
    t.datetime "thread_updated_ts",              null: false
    t.string   "image"
    t.string   "cached_tag_list"
    t.integer  "total_upvotes"
    t.hstore   "props",             default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entities", ["scoring_rule_id"], :name => "index_entities_on_scoring_rule_id"

  create_table "entity_refs", force: true do |t|
    t.integer "from_id", null: false
    t.integer "to_id",   null: false
  end

  add_index "entity_refs", ["from_id", "to_id"], :name => "index_entity_refs_on_from_id_and_to_id", :unique => true
  add_index "entity_refs", ["from_id"], :name => "index_entity_refs_on_from_id"
  add_index "entity_refs", ["to_id"], :name => "index_entity_refs_on_to_id"

  create_table "events", force: true do |t|
    t.string   "type_name"
    t.string   "feed_name"
    t.string   "content_digest"
    t.hstore   "props",          default: {}
    t.json     "source_data"
    t.integer  "entity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["content_digest"], :name => "index_events_on_content_digest"

  create_table "filters", force: true do |t|
    t.integer "embed_id"
    t.boolean "is_conj"
    t.string  "classification"
    t.integer "filterable_id"
    t.string  "filterable_type"
  end

  create_table "identities", force: true do |t|
    t.string  "provider"
    t.json    "source_data",           default: {}
    t.integer "user_id"
    t.integer "uid",         limit: 8
  end

  add_index "identities", ["provider", "uid"], :name => "index_identities_on_provider_and_uid", :unique => true
  add_index "identities", ["user_id"], :name => "index_identities_on_user_id"

  create_table "internals", force: true do |t|
    t.integer  "actor_id"
    t.integer  "receiver_id",   null: false
    t.integer  "applies_to_id"
    t.string   "variant"
    t.string   "comment"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "internals", ["actor_id"], :name => "index_internals_on_actor_id"
  add_index "internals", ["receiver_id"], :name => "index_internals_on_receiver_id"

  create_table "natlang_queries", force: true do |t|
    t.string  "attr"
    t.string  "op"
    t.string  "val"
    t.boolean "is_negated", default: false
    t.integer "filter_id"
  end

  create_table "ownerships", force: true do |t|
    t.integer  "owner_id"
    t.integer  "entity_id"
    t.integer  "value"
    t.string   "ownership_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ownerships", ["entity_id"], :name => "index_ownerships_on_entity_id"
  add_index "ownerships", ["owner_id"], :name => "index_ownerships_on_owner_id"

  create_table "rewards", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "point_minimum"
    t.string   "image"
    t.datetime "disabled_ts"
    t.hstore   "props",         default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scoring_rules", force: true do |t|
    t.string   "name"
    t.hstore   "required_tags",    default: {}
    t.integer  "authorship_value", default: 0
    t.integer  "award_value",      default: 0
    t.integer  "upvote_value",     default: 0
    t.hstore   "props",            default: {}
    t.integer  "position"
    t.datetime "valid_until"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "services", force: true do |t|
    t.integer  "embed_id"
    t.string   "feed_name"
    t.json     "json_config"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "services", ["embed_id"], :name => "index_services_on_embed_id"

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], :name => "taggings_idx", :unique => true

  create_table "tags", force: true do |t|
    t.string  "name",                        null: false
    t.string  "display_name"
    t.string  "aliases",        default: [],              array: true
    t.hstore  "props",          default: {}
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "upvotes", force: true do |t|
    t.integer  "applies_to_id", null: false
    t.integer  "actor_id",      null: false
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "upvotes", ["actor_id"], :name => "index_upvotes_on_actor_id"
  add_index "upvotes", ["applies_to_id"], :name => "index_upvotes_on_applies_to_id"

  create_table "user_roles", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_roles", ["name", "resource_type", "resource_id"], :name => "index_user_roles_on_name_and_resource_type_and_resource_id"
  add_index "user_roles", ["name"], :name => "index_user_roles_on_name"

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "address"
    t.string   "address2"
    t.string   "city"
    t.string   "postal"
    t.string   "state"
    t.hstore   "props",               default: {}
    t.integer  "total_score",         default: 0
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "users", ["country_id"], :name => "index_users_on_country_id"
  add_index "users", ["email"], :name => "index_users_on_email"

  create_table "users_user_roles", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "user_role_id"
  end

  add_index "users_user_roles", ["user_id", "user_role_id"], :name => "index_users_user_roles_on_user_id_and_user_role_id"

  create_view "public.entity_aggregated_tag_list", <<-SQL
     SELECT e.id AS entity_id,
    string_agg((t.name)::text, ','::text) AS tag_list
   FROM entities e,
    tags t,
    taggings e_t
  WHERE ((e.id = e_t.taggable_id) AND (e_t.tag_id = t.id))
  GROUP BY e.id;
  SQL
  create_view "public.user_total_score", <<-SQL
     SELECT users.id AS user_id,
    (((( SELECT COALESCE(sum(o.value), (0)::bigint) AS "coalesce"
           FROM entities e,
            ownerships o
          WHERE ((e.id = o.entity_id) AND (o.owner_id = users.id))) + ( SELECT COALESCE(sum(u.value), (0)::bigint) AS "coalesce"
           FROM entities e,
            ownerships o,
            upvotes u
          WHERE (((u.applies_to_id = e.id) AND (e.id = o.entity_id)) AND (o.owner_id = users.id)))) + ( SELECT COALESCE(sum(a.value), (0)::bigint) AS "coalesce"
           FROM entities e,
            ownerships o,
            awards a
          WHERE (((a.applies_to_id = e.id) AND (e.id = o.entity_id)) AND (o.owner_id = users.id)))) + ( SELECT COALESCE(sum(i.value), (0)::bigint) AS "coalesce"
           FROM internals i
          WHERE (i.receiver_id = users.id))) AS score_sum
   FROM users;
  SQL
  create_view "public.entity_total_upvotes", <<-SQL
     SELECT e.id AS entity_id,
    sum(u.value) AS upvotes_sum
   FROM entities e,
    upvotes u
  WHERE (e.id = u.applies_to_id)
  GROUP BY e.id;
  SQL

  add_foreign_key "accounts_brands", "public.accounts", :name => "accounts_brands_account_id_fk", :column => "account_id", :dependent => :delete, :exclude_index => true
  add_foreign_key "accounts_brands", "public.brands", :name => "accounts_brands_brand_id_fk", :column => "brand_id", :dependent => :delete, :exclude_index => true

  add_foreign_key "achievements", "public.rewards", :name => "achievements_reward_id_fk", :column => "reward_id", :dependent => :delete, :exclude_index => true
  add_foreign_key "achievements", "public.users", :name => "achievements_user_id_fk", :column => "user_id", :dependent => :delete, :exclude_index => true

  add_foreign_key "awards", "public.entities", :name => "awards_applies_to_id_fk", :column => "applies_to_id", :dependent => :delete, :exclude_index => true
  add_foreign_key "awards", "public.users", :name => "awards_actor_id_fk", :column => "actor_id", :dependent => :delete, :exclude_index => true

  add_foreign_key "brand_identities", "public.brands", :name => "brand_identities_brand_id_fk", :column => "brand_id", :dependent => :delete, :exclude_index => true

  add_foreign_key "brands_users", "public.brands", :name => "brands_users_brand_id_fk", :column => "brand_id", :dependent => :delete, :exclude_index => true
  add_foreign_key "brands_users", "public.users", :name => "brands_users_user_id_fk", :column => "user_id", :dependent => :delete, :exclude_index => true

  add_foreign_key "embeds", "public.brands", :name => "embeds_brand_id_fk", :column => "brand_id", :dependent => :delete, :exclude_index => true

  add_foreign_key "entities", "public.scoring_rules", :name => "entities_scoring_rule_id_fk", :column => "scoring_rule_id", :exclude_index => true

  add_foreign_key "internals", "public.users", :name => "internals_actor_id_fk", :column => "actor_id", :dependent => :delete, :exclude_index => true
  add_foreign_key "internals", "public.users", :name => "internals_receiver_id_fk", :column => "receiver_id", :dependent => :delete, :exclude_index => true

  add_foreign_key "ownerships", "public.entities", :name => "ownerships_entity_id_fk", :column => "entity_id", :dependent => :delete, :exclude_index => true
  add_foreign_key "ownerships", "public.users", :name => "ownerships_owner_id_fk", :column => "owner_id", :dependent => :delete, :exclude_index => true

  add_foreign_key "services", "public.embeds", :name => "services_embed_id_fk", :column => "embed_id", :dependent => :delete, :exclude_index => true

  add_foreign_key "upvotes", "public.entities", :name => "upvotes_applies_to_id_fk", :column => "applies_to_id", :dependent => :delete, :exclude_index => true
  add_foreign_key "upvotes", "public.users", :name => "upvotes_actor_id_fk", :column => "actor_id", :dependent => :delete, :exclude_index => true

  add_foreign_key "users", "public.countries", :name => "users_country_id_fk", :column => "country_id", :exclude_index => true

end
