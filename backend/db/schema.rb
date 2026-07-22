# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_22_190000) do
  create_table "support_requests", force: :cascade do |t|
    t.integer "assignee_id"
    t.datetime "created_at", null: false
    t.integer "creator_id", null: false
    t.text "description", null: false
    t.date "due_date"
    t.integer "priority", default: 1, null: false
    t.datetime "resolved_at"
    t.integer "status", default: 0, null: false
    t.integer "team_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_support_requests_on_assignee_id"
    t.index ["creator_id"], name: "index_support_requests_on_creator_id"
    t.index ["due_date"], name: "index_support_requests_on_due_date"
    t.index ["priority"], name: "index_support_requests_on_priority"
    t.index ["status"], name: "index_support_requests_on_status"
    t.index ["team_id"], name: "index_support_requests_on_team_id"
  end

  create_table "team_members", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_team_members_on_email", unique: true
  end

  add_foreign_key "support_requests", "team_members", column: "assignee_id"
  add_foreign_key "support_requests", "team_members", column: "creator_id"
  add_foreign_key "support_requests", "team_members", column: "team_id"
end
