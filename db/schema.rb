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

ActiveRecord::Schema.define(version: 20171027022715) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pgcrypto"

  create_table "countries", force: :cascade do |t|
    t.string   "country_code",      null: false
    t.integer  "panel_provider_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "countries", ["panel_provider_id"], name: "index_countries_on_panel_provider_id", using: :btree

  create_table "location_group_assignments", force: :cascade do |t|
    t.integer  "location_group_id"
    t.integer  "location_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "location_group_assignments", ["location_group_id"], name: "index_location_group_assignments_on_location_group_id", using: :btree
  add_index "location_group_assignments", ["location_id"], name: "index_location_group_assignments_on_location_id", using: :btree

  create_table "location_groups", force: :cascade do |t|
    t.string   "name",              null: false
    t.integer  "country_id"
    t.integer  "panel_provider_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "location_groups", ["country_id"], name: "index_location_groups_on_country_id", using: :btree
  add_index "location_groups", ["panel_provider_id"], name: "index_location_groups_on_panel_provider_id", using: :btree

  create_table "locations", force: :cascade do |t|
    t.string   "name",                                            null: false
    t.uuid     "external_id",       default: "gen_random_uuid()"
    t.integer  "panel_provider_id"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "locations", ["panel_provider_id"], name: "index_locations_on_panel_provider_id", using: :btree

  create_table "panel_providers", force: :cascade do |t|
    t.string   "code",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "countries", "panel_providers"
  add_foreign_key "location_group_assignments", "location_groups"
  add_foreign_key "location_group_assignments", "locations"
  add_foreign_key "location_groups", "countries"
  add_foreign_key "location_groups", "panel_providers"
  add_foreign_key "locations", "panel_providers"
end
