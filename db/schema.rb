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

ActiveRecord::Schema.define(version: 2020_06_23_185119) do

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

  create_table "employees", force: :cascade do |t|
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["type"], name: "index_employees_on_type"
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
    t.string "status"
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

  create_table "reviews", force: :cascade do |t|
    t.integer "task_id", null: false
    t.integer "user_id", null: false
    t.boolean "approved"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "roller_comments", force: :cascade do |t|
    t.string "type"
    t.integer "roller_id"
    t.integer "user_id"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roller_types", force: :cascade do |t|
    t.string "name"
    t.string "icon"
    t.string "color"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.index ["name"], name: "index_roller_types_on_name"
    t.index ["type"], name: "index_roller_types_on_type"
  end

  create_table "task_assignees", force: :cascade do |t|
    t.integer "task_id"
    t.integer "assignee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string "status"
    t.index ["closed"], name: "index_tasks_on_closed"
    t.index ["issue_id"], name: "index_tasks_on_issue_id"
    t.index ["project_id"], name: "index_tasks_on_project_id"
    t.index ["task_type_id"], name: "index_tasks_on_task_type_id"
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.integer "employee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["employee_id"], name: "index_users_on_employee_id"
  end

end
