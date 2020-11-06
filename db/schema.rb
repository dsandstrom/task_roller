# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_11_06_005827) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.boolean "visible", default: true
    t.boolean "internal", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["internal"], name: "index_categories_on_internal"
    t.index ["visible"], name: "index_categories_on_visible"
  end

  create_table "category_issues_subscriptions", force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "category_tasks_subscriptions", force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "issue_comments", force: :cascade do |t|
    t.integer "issue_id", null: false
    t.integer "user_id", null: false
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "issue_connections", force: :cascade do |t|
    t.integer "source_id", null: false
    t.integer "target_id", null: false
    t.string "scheme"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "issue_subscriptions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "issue_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "issue_types", force: :cascade do |t|
    t.string "name", null: false
    t.string "icon", null: false
    t.string "color", null: false
    t.integer "position"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "issues", force: :cascade do |t|
    t.string "summary"
    t.text "description"
    t.integer "issue_type_id"
    t.integer "user_id"
    t.integer "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "closed", default: false, null: false
    t.datetime "opened_at", precision: 6
    t.integer "tasks_count", default: 0, null: false
    t.integer "open_tasks_count", default: 0, null: false
    t.index ["closed"], name: "index_issues_on_closed"
    t.index ["issue_type_id"], name: "index_issues_on_issue_type_id"
    t.index ["project_id"], name: "index_issues_on_project_id"
    t.index ["user_id"], name: "index_issues_on_user_id"
  end

  create_table "progressions", force: :cascade do |t|
    t.integer "task_id", null: false
    t.integer "user_id", null: false
    t.boolean "finished", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "finished_at", precision: 6
  end

  create_table "project_issues_subscriptions", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "project_tasks_subscriptions", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.boolean "visible", default: true
    t.boolean "internal", default: false
    t.integer "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_projects_on_category_id"
    t.index ["internal"], name: "index_projects_on_internal"
    t.index ["visible"], name: "index_projects_on_visible"
  end

  create_table "resolutions", force: :cascade do |t|
    t.integer "issue_id", null: false
    t.integer "user_id", null: false
    t.boolean "approved"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "task_id", null: false
    t.integer "user_id", null: false
    t.boolean "approved"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "task_assignees", force: :cascade do |t|
    t.integer "task_id"
    t.integer "assignee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "task_comments", force: :cascade do |t|
    t.integer "task_id", null: false
    t.integer "user_id", null: false
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "task_connections", force: :cascade do |t|
    t.integer "source_id", null: false
    t.integer "target_id", null: false
    t.string "scheme"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "task_subscriptions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "task_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "task_types", force: :cascade do |t|
    t.string "name", null: false
    t.string "icon", null: false
    t.string "color", null: false
    t.integer "position"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.string "summary"
    t.text "description"
    t.integer "task_type_id"
    t.integer "issue_id"
    t.integer "user_id"
    t.integer "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "closed", default: false, null: false
    t.datetime "opened_at", precision: 6
    t.index ["closed"], name: "index_tasks_on_closed"
    t.index ["issue_id"], name: "index_tasks_on_issue_id"
    t.index ["project_id"], name: "index_tasks_on_project_id"
    t.index ["task_type_id"], name: "index_tasks_on_task_type_id"
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "employee_type"
    t.index ["email"], name: "index_users_on_email"
  end

end
