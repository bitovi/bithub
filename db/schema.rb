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

ActiveRecord::Schema.define(version: 20150821192603) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "intarray"
  enable_extension "btree_gin"

  create_table "account_organizations", force: :cascade do |t|
    t.integer  "account_id",             null: false
    t.integer  "organization_id",        null: false
    t.datetime "invitation_created_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invited_by_account_id"
  end

  add_index "account_organizations", ["account_id", "organization_id"], name: "no_double_links", unique: true, using: :btree

  create_table "account_roles", force: :cascade do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "account_roles", ["name", "resource_type", "resource_id"], name: "index_account_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "account_roles", ["name"], name: "index_account_roles_on_name", using: :btree

  create_table "accounts", force: :cascade do |t|
    t.string   "name"
    t.hstore   "props",                  default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: ""
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
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invitations_count",      default: 0
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
  end

  add_index "accounts", ["email"], name: "index_accounts_on_email", unique: true, using: :btree
  add_index "accounts", ["invitation_token"], name: "index_accounts_on_invitation_token", unique: true, using: :btree
  add_index "accounts", ["invitations_count"], name: "index_accounts_on_invitations_count", using: :btree
  add_index "accounts", ["invited_by_id"], name: "index_accounts_on_invited_by_id", using: :btree
  add_index "accounts", ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true, using: :btree

  create_table "accounts_account_roles", id: false, force: :cascade do |t|
    t.integer "account_id"
    t.integer "account_role_id"
  end

  add_index "accounts_account_roles", ["account_id", "account_role_id"], name: "index_accounts_account_roles_on_account_id_and_account_role_id", using: :btree

  create_table "brand_identities", force: :cascade do |t|
    t.string   "provider"
    t.string   "uid"
    t.json     "source_data",    default: {}
    t.integer  "brand_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json     "extracted_data", default: {}
  end

  create_table "brands", force: :cascade do |t|
    t.string   "name"
    t.string   "tenant_name"
    t.hstore   "props",           default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
    t.boolean  "is_active",       default: true
  end

  add_index "brands", ["name"], name: "index_brands_on_name", unique: true, using: :btree
  add_index "brands", ["tenant_name"], name: "index_brands_on_tenant_name", unique: true, using: :btree

  create_table "brands_users", force: :cascade do |t|
    t.integer "user_id"
    t.integer "brand_id"
    t.integer "total_score", default: 0
    t.hstore  "props",       default: {}
  end

  create_table "countries", force: :cascade do |t|
    t.string  "name",                     null: false
    t.string  "display_name"
    t.string  "iso",                      null: false
    t.integer "priority",     default: 0
  end

  create_table "embed_entities", force: :cascade do |t|
    t.integer  "embed_id"
    t.integer  "entity_id"
    t.boolean  "is_approved_manually"
    t.boolean  "is_pinned",                 default: false, null: false
    t.boolean  "is_approved_automatically"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "embed_entities", ["entity_id"], name: "embed_entities_entity_id_idx", using: :btree

  create_table "embed_events", force: :cascade do |t|
    t.integer  "organization_id"
    t.integer  "brand_id"
    t.integer  "embed_id"
    t.string   "organization_name"
    t.string   "brand_name"
    t.string   "embed_name"
    t.string   "action"
    t.string   "attr",              default: ""
    t.string   "old_value",         default: ""
    t.string   "new_value",         default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "embed_presets", force: :cascade do |t|
    t.integer  "embed_id"
    t.string   "name"
    t.json     "config"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "embeds", force: :cascade do |t|
    t.string   "name"
    t.integer  "brand_id"
    t.boolean  "approved_by_default", default: true
    t.boolean  "published",           default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "entities", force: :cascade do |t|
    t.text     "title"
    t.text     "url"
    t.text     "body"
    t.string   "origin_id"
    t.string   "feed_name"
    t.string   "type_name"
    t.integer  "parent_id"
    t.datetime "origin_ts",                          null: false
    t.datetime "thread_updated_ts",                  null: false
    t.string   "image"
    t.string   "cached_tag_list"
    t.integer  "total_upvotes"
    t.hstore   "props",              default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_pending",         default: false
    t.text     "searchable_content"
    t.text     "searchable_title"
    t.text     "searchable_body"
    t.text     "searchable_author"
    t.integer  "popularity",         default: 0
  end

  add_index "entities", ["feed_name"], name: "entities_feed_name_idx", using: :gin
  add_index "entities", ["origin_id"], name: "entities_origin_id_idx", using: :btree
  add_index "entities", ["parent_id"], name: "entities_parent_id_idx", using: :btree
  add_index "entities", ["type_name"], name: "entities_type_name_idx", using: :gin

  create_table "events", force: :cascade do |t|
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
    t.boolean  "is_processed",   default: false
    t.boolean  "was_viewed",     default: false
  end

  add_index "events", ["content_digest"], name: "index_events_on_content_digest", using: :btree

  create_table "filters", force: :cascade do |t|
    t.integer "embed_id"
    t.string  "action",   null: false
  end

  create_table "histogram", id: false, force: :cascade do |t|
    t.string   "source_type"
    t.integer  "source_id"
    t.integer  "volume"
    t.integer  "delta"
    t.datetime "measured_at"
  end

  add_index "histogram", ["source_type", "source_id", "measured_at"], name: "histogram_unique_source_measured_at", unique: true, using: :btree

  create_table "interactions", id: false, force: :cascade do |t|
    t.string   "event_type"
    t.string   "event_subtype"
    t.integer  "primary_source_id"
    t.string   "primary_source_type"
    t.integer  "secondary_source_id"
    t.string   "secondary_source_type"
    t.datetime "created_at"
  end

  create_table "invite_codes", force: :cascade do |t|
    t.string   "code"
    t.integer  "remaining_uses"
    t.datetime "valid_until"
  end

  create_table "monthly_billing_records", force: :cascade do |t|
    t.integer  "monthly_billing_id"
    t.string   "description"
    t.integer  "amount",             default: 0
    t.integer  "price",              default: 0
    t.string   "currency",           default: "USD"
    t.hstore   "props",              default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "monthly_billings", force: :cascade do |t|
    t.integer  "organization_id"
    t.datetime "period_beginning"
    t.datetime "period_end"
    t.integer  "total"
    t.string   "currency",           default: "USD"
    t.text     "description"
    t.string   "stripe_customer_id"
    t.string   "stripe_charge_id"
    t.string   "stripe_status"
    t.datetime "charged_at"
    t.hstore   "props",              default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "natlang_queries", force: :cascade do |t|
    t.string  "attr_name"
    t.string  "op"
    t.string  "val"
    t.boolean "is_negated", default: false
    t.integer "filter_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payments", force: :cascade do |t|
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

  create_table "plans", force: :cascade do |t|
    t.string  "stripe_id"
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

  create_table "service_entities", force: :cascade do |t|
    t.integer "service_id"
    t.integer "entity_id"
  end

  add_index "service_entities", ["entity_id", "service_id"], name: "index_service_entities_on_entity_id_and_service_id", using: :btree
  add_index "service_entities", ["entity_id"], name: "service_entities_entity_id_idx", using: :btree
  add_index "service_entities", ["service_id"], name: "index_service_entities_on_service_id", using: :btree

  create_table "service_errors", force: :cascade do |t|
    t.string   "klass"
    t.string   "message"
    t.text     "backtrace"
    t.integer  "service_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "services", force: :cascade do |t|
    t.integer  "embed_id"
    t.string   "feed_name"
    t.string   "type_name"
    t.json     "config"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uid"
    t.integer  "brand_identity_id"
    t.boolean  "approved_by_default"
    t.string   "state",               default: "loading"
  end

  create_table "stripe_webhooks_log", force: :cascade do |t|
    t.string   "event_id"
    t.json     "target"
    t.json     "event"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscriptions", force: :cascade do |t|
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

  create_table "users", force: :cascade do |t|
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

  add_index "users", ["email"], name: "index_users_on_email", using: :btree

  add_foreign_key "embed_entities", "embeds", name: "fk_embed_entities_to_embeds", on_delete: :cascade
  add_foreign_key "embed_entities", "entities", name: "fk_embed_entities_to_entities", on_delete: :cascade
  add_foreign_key "embed_presets", "embeds", name: "fk_embed_presets_to_embeds", on_delete: :cascade
  add_foreign_key "events", "entities", name: "fk_events_to_entities", on_delete: :cascade
  add_foreign_key "filters", "embeds", name: "fk_filters_to_embeds", on_delete: :cascade
  add_foreign_key "natlang_queries", "filters", name: "fk_natlang_queries_to_filters", on_delete: :cascade
  add_foreign_key "service_entities", "entities", name: "fk_service_entities_to_entities", on_delete: :cascade
  add_foreign_key "service_entities", "services", name: "fk_service_entities_to_services", on_delete: :cascade
  add_foreign_key "service_errors", "services", name: "fk_service_errors_to_services", on_delete: :cascade
end
