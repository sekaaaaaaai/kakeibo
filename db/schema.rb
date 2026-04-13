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

ActiveRecord::Schema[8.1].define(version: 2026_04_14_150000) do
  create_table "categories", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "color", default: "#64748b", null: false
    t.datetime "created_at", null: false
    t.string "kind", default: "expense", null: false
    t.string "name", null: false
    t.integer "sort_order", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["kind", "sort_order"], name: "index_categories_on_kind_and_sort_order"
    t.index ["name", "kind"], name: "index_categories_on_name_and_kind", unique: true
  end

  create_table "groups", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_groups_on_name", unique: true
  end

  create_table "monthly_budgets", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.date "month", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id", "month"], name: "index_monthly_budgets_on_category_id_and_month", unique: true
    t.index ["category_id"], name: "index_monthly_budgets_on_category_id"
  end

  create_table "transactions", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "aggregation_scope", null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.string "memo"
    t.date "occurred_on", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["aggregation_scope"], name: "index_transactions_on_aggregation_scope"
    t.index ["category_id"], name: "index_transactions_on_category_id"
    t.index ["occurred_on"], name: "index_transactions_on_occurred_on"
    t.index ["user_id", "occurred_on"], name: "index_transactions_on_user_id_and_occurred_on"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "group_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "name"], name: "index_users_on_group_id_and_name", unique: true
    t.index ["group_id"], name: "index_users_on_group_id"
  end

  add_foreign_key "monthly_budgets", "categories"
  add_foreign_key "transactions", "categories"
  add_foreign_key "transactions", "users"
  add_foreign_key "users", "groups"
end
