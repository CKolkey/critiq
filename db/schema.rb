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

ActiveRecord::Schema.define(version: 2019_06_13_075955) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "choices", force: :cascade do |t|
    t.bigint "question_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_choices_on_question_id"
  end

  create_table "questions", force: :cascade do |t|
    t.string "name"
    t.boolean "multiple_choice"
    t.string "question_type"
    t.bigint "survey_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_id"], name: "index_questions_on_survey_id"
  end

  create_table "recipients", force: :cascade do |t|
    t.string "uid"
    t.string "first_name", default: ""
    t.string "last_name", default: ""
    t.bigint "survey_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_id"], name: "index_recipients_on_survey_id"
  end

  create_table "responses", force: :cascade do |t|
    t.string "slack_uid"
    t.string "content"
    t.bigint "question_id"
    t.bigint "choice_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "sent_question_id"
    t.index ["choice_id"], name: "index_responses_on_choice_id"
    t.index ["question_id"], name: "index_responses_on_question_id"
    t.index ["sent_question_id"], name: "index_responses_on_sent_question_id"
  end

  create_table "sent_questions", force: :cascade do |t|
    t.bigint "question_id"
    t.string "recipent_slack_uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_sent_questions_on_question_id"
  end

  create_table "slackbotdevs", force: :cascade do |t|
    t.string "slack_channel"
    t.string "slack_user"
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "surveys", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.string "channel_id"
    t.boolean "published", default: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_surveys_on_user_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "team_id"
    t.string "name"
    t.boolean "active", default: true
    t.string "domain"
    t.string "token"
    t.string "bot_user_id"
    t.string "bot_access_token"
    t.string "activated_user_id"
    t.string "activated_user_access_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.string "nickname"
    t.string "team_id"
    t.boolean "admin", default: false, null: false
    t.string "first_name"
    t.string "last_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "choices", "questions"
  add_foreign_key "questions", "surveys"
  add_foreign_key "recipients", "surveys"
  add_foreign_key "responses", "choices"
  add_foreign_key "responses", "questions"
  add_foreign_key "responses", "sent_questions"
  add_foreign_key "sent_questions", "questions"
  add_foreign_key "surveys", "users"
end
