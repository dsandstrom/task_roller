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

ActiveRecord::Schema.define(version: 20180127033058) do

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
    t.index ["issue_type_id"], name: "index_issues_on_issue_type_id"
    t.index ["project_id"], name: "index_issues_on_project_id"
    t.index ["user_id"], name: "index_issues_on_user_id"
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

  create_table "roller_types", force: :cascade do |t|
    t.string "name"
    t.string "icon"
    t.string "color"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roller_types_on_name"
    t.index ["type"], name: "index_roller_types_on_type"
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
