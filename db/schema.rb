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

ActiveRecord::Schema.define(version: 20150324150405) do


  create_extension "hstore", :version => "1.3"
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
    t.integer  "invite_code_id"
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

  create_table "accounts_organizations", id: false, force: true do |t|
    t.integer "account_id",      null: false
    t.integer "organization_id", null: false
  end

  create_table "brand_identities", force: true do |t|
    t.string   "provider"
    t.string   "uid"
    t.json     "source_data",    default: {}
    t.integer  "brand_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json     "extracted_data"
  end

  add_index "brand_identities", ["brand_id"], :name => "index_brand_identities_on_brand_id"

  create_table "brands", force: true do |t|
    t.string   "name"
    t.string   "tenant_name"
    t.hstore   "props",           default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
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
    t.boolean "is_pinned",   default: false, null: false
  end

  create_table "embed_presets", force: true do |t|
    t.integer  "embed_id"
    t.string   "name"
    t.json     "config"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "embeds", force: true do |t|
    t.string  "name"
    t.integer "brand_id"
    t.boolean "approved_by_default", default: true
  end

  add_index "embeds", ["brand_id"], :name => "index_embeds_on_brand_id"

  create_table "entities", force: true do |t|
    t.text     "title"
    t.text     "url"
    t.text     "body"
    t.string   "origin_id"
    t.string   "feed_name"
    t.string   "type_name"
    t.integer  "parent_id"
    t.datetime "origin_ts",                         null: false
    t.datetime "thread_updated_ts",                 null: false
    t.string   "image"
    t.string   "cached_tag_list"
    t.integer  "total_upvotes"
    t.hstore   "props",             default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_pending",        default: false
  end

  create_table "events", force: true do |t|
    t.string   "type_name"
    t.string   "feed_name"
    t.string   "content_digest"
    t.hstore   "props",          default: {}
    t.json     "source_data"
    t.integer  "entity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "embed_id"
    t.integer  "service_id"
  end

  add_index "events", ["content_digest"], :name => "index_events_on_content_digest"

  create_table "filters", force: true do |t|
    t.integer "embed_id"
    t.boolean "is_conj"
    t.string  "classification"
  end

  create_table "histogram", id: false, force: true do |t|
    t.string   "source_type"
    t.integer  "source_id"
    t.integer  "volume"
    t.integer  "delta"
    t.datetime "measured_at"
  end

  add_index "histogram", ["source_type", "source_id", "measured_at"], :name => "histogram_unique_source_measured_at", :unique => true

  create_table "invite_codes", force: true do |t|
    t.string   "code"
    t.integer  "remaining_uses"
    t.datetime "valid_until"
  end

  create_table "natlang_queries", force: true do |t|
    t.string  "attr"
    t.string  "op"
    t.string  "val"
    t.boolean "is_negated", default: false
    t.integer "filter_id"
  end

  create_table "organizations", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "payments", force: true do |t|
    t.integer  "total"
    t.string   "currency",               limit: 3
    t.datetime "period_start"
    t.datetime "period_end"
    t.string   "plan_id"
    t.string   "stripe_event_id"
    t.string   "stripe_invoice_id"
    t.string   "stripe_customer_id"
    t.string   "stripe_subscription_id"
    t.hstore   "props"
    t.integer  "subscription_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plans", force: true do |t|
    t.string  "stripe_id",                           null: false
    t.string  "name",                                null: false
    t.text    "description"
    t.integer "amount",                              null: false
    t.string  "currency",          default: "usd",   null: false
    t.string  "interval",          default: "month", null: false
    t.integer "interval_count",    default: 1,       null: false
    t.integer "trail_period_days", default: 30,      null: false
    t.integer "grace_period",      default: 15,      null: false
    t.json    "limits",            default: {},      null: false
    t.json    "features",          default: {},      null: false
    t.boolean "available",         default: false
  end

  create_table "service_entities", force: true do |t|
    t.integer "service_id"
    t.integer "entity_id"
  end

  add_index "service_entities", ["entity_id", "service_id"], :name => "index_service_entities_on_entity_id_and_service_id"
  add_index "service_entities", ["service_id"], :name => "index_service_entities_on_service_id"

  create_table "service_errors", force: true do |t|
    t.string   "klass"
    t.string   "message"
    t.text     "backtrace"
    t.integer  "service_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "services", force: true do |t|
    t.integer  "embed_id"
    t.string   "feed_name"
    t.string   "type_name"
    t.json     "config"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uid"
    t.integer  "brand_identity_id"
  end

  add_index "services", ["embed_id"], :name => "index_services_on_embed_id"

  create_table "stripe_webhooks_log", force: true do |t|
    t.string   "event_id"
    t.json     "target"
    t.json     "event"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscriptions", force: true do |t|
    t.integer  "organization_id"
    t.string   "stripe_event_id"
    t.string   "stripe_customer_id"
    t.string   "stripe_subscription_id"
    t.string   "stripe_subscription_status"
    t.string   "card_token"
    t.string   "card_exp_month"
    t.string   "card_exp_year"
    t.string   "card_type"
    t.string   "card_last4",                 limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "plan_id"
  end

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

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "address"
    t.string   "address2"
    t.string   "city"
    t.string   "postal"
    t.string   "state"
    t.hstore   "props",       default: {}
    t.integer  "total_score", default: 0
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["country_id"], :name => "index_users_on_country_id"
  add_index "users", ["email"], :name => "index_users_on_email"

  create_view "public.entity_aggregated_tag_list", <<-SQL
     SELECT e.id AS entity_id,
    string_agg((t.name)::text, ','::text) AS tag_list
   FROM entities e,
    tags t,
    taggings e_t
  WHERE ((e.id = e_t.taggable_id) AND (e_t.tag_id = t.id))
  GROUP BY e.id;
  SQL

  add_foreign_key "accounts_brands", "public.accounts", :name => "accounts_brands_account_id_fk", :column => "account_id", :dependent => :delete, :exclude_index => true
  add_foreign_key "accounts_brands", "public.brands", :name => "accounts_brands_brand_id_fk", :column => "brand_id", :dependent => :delete, :exclude_index => true

  add_foreign_key "brand_identities", "public.brands", :name => "brand_identities_brand_id_fk", :column => "brand_id", :dependent => :delete, :exclude_index => true

  add_foreign_key "brands_users", "public.brands", :name => "brands_users_brand_id_fk", :column => "brand_id", :dependent => :delete, :exclude_index => true
  add_foreign_key "brands_users", "public.users", :name => "brands_users_user_id_fk", :column => "user_id", :dependent => :delete, :exclude_index => true

  add_foreign_key "embeds", "public.brands", :name => "embeds_brand_id_fk", :column => "brand_id", :dependent => :delete, :exclude_index => true

  add_foreign_key "ownerships", "public.entities", :name => "ownerships_entity_id_fk", :column => "entity_id", :dependent => :delete, :exclude_index => true
  add_foreign_key "ownerships", "public.users", :name => "ownerships_owner_id_fk", :column => "owner_id", :dependent => :delete, :exclude_index => true

  add_foreign_key "services", "public.embeds", :name => "services_embed_id_fk", :column => "embed_id", :dependent => :delete, :exclude_index => true

  add_foreign_key "users", "public.countries", :name => "users_country_id_fk", :column => "country_id", :exclude_index => true

end
