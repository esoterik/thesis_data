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

ActiveRecord::Schema.define(version: 20180427054749) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assignments", force: :cascade do |t|
    t.bigint "issue_id"
    t.bigint "pull_request_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_id"], name: "index_assignments_on_issue_id"
    t.index ["pull_request_id"], name: "index_assignments_on_pull_request_id"
    t.index ["user_id"], name: "index_assignments_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "conversation_id"
    t.bigint "author_id"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "time"
    t.integer "category"
    t.decimal "sentiment"
    t.decimal "sadness"
    t.decimal "joy"
    t.decimal "fear"
    t.decimal "disgust"
    t.decimal "anger"
    t.integer "length"
    t.index ["author_id"], name: "index_comments_on_author_id"
    t.index ["conversation_id"], name: "index_comments_on_conversation_id"
  end

  create_table "commits", force: :cascade do |t|
    t.datetime "time", null: false
    t.integer "diff"
    t.integer "additions"
    t.integer "deletions"
    t.text "message"
    t.bigint "user_id"
    t.bigint "repo_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sha"
    t.index ["repo_id"], name: "index_commits_on_repo_id"
    t.index ["user_id"], name: "index_commits_on_user_id"
  end

  create_table "contributions", force: :cascade do |t|
    t.integer "count", null: false
    t.bigint "user_id", null: false
    t.bigint "repo_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "first_pr"
    t.datetime "first_commit"
    t.datetime "last_commit"
    t.boolean "active"
    t.decimal "length"
    t.decimal "frequency"
    t.decimal "diff"
    t.decimal "avg_commit_size"
    t.datetime "last_pr"
    t.integer "first_pr_status"
    t.integer "last_pr_status"
    t.integer "commits_at_first_pr"
    t.boolean "more_than_a_year"
    t.integer "total_commits"
    t.integer "total_prs"
    t.integer "total_adds"
    t.integer "total_dels"
    t.datetime "first_issue_opened"
    t.index ["repo_id"], name: "index_contributions_on_repo_id"
    t.index ["user_id"], name: "index_contributions_on_user_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "issue_id"
    t.bigint "pull_request_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "excluded"
    t.index ["issue_id"], name: "index_conversations_on_issue_id"
    t.index ["pull_request_id"], name: "index_conversations_on_pull_request_id"
  end

  create_table "issues", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.datetime "opened"
    t.datetime "closed"
    t.integer "status"
    t.integer "number"
    t.bigint "author_id"
    t.bigint "repo_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_issues_on_author_id"
    t.index ["repo_id"], name: "index_issues_on_repo_id"
  end

  create_table "pull_requests", force: :cascade do |t|
    t.integer "status"
    t.datetime "opened"
    t.datetime "closed"
    t.string "title"
    t.text "body"
    t.integer "number"
    t.bigint "author_id"
    t.bigint "repo_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "additions"
    t.integer "deletions"
    t.integer "changed_files"
    t.integer "diff"
    t.index ["author_id"], name: "index_pull_requests_on_author_id"
    t.index ["repo_id"], name: "index_pull_requests_on_repo_id"
  end

  create_table "repos", force: :cascade do |t|
    t.string "name", null: false
    t.string "languages"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "owner"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "username", null: false
    t.string "email"
    t.integer "gender_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "location"
    t.string "bio"
    t.string "company"
    t.string "first_name"
    t.string "blog"
    t.decimal "gender_prob"
    t.boolean "excluded"
    t.decimal "sentiment_toward_notable"
    t.decimal "sentiment_toward_other"
    t.decimal "sentiment_by"
  end

end
