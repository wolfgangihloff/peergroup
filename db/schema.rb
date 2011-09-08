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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110908130506) do

  create_table "answers", :force => true do |t|
    t.text     "content"
    t.integer  "question_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "answers", ["question_id"], :name => "index_answers_on_question_id"
  add_index "answers", ["user_id"], :name => "index_answers_on_user_id"

  create_table "chat_messages", :force => true do |t|
    t.text     "content"
    t.integer  "user_id"
    t.integer  "chat_room_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "chat_messages", ["chat_room_id"], :name => "index_chat_messages_on_chat_room_id"
  add_index "chat_messages", ["user_id"], :name => "index_chat_messages_on_user_id"

  create_table "chat_rooms", :force => true do |t|
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "leader_id"
    t.integer  "problem_owner_id"
    t.integer  "supervision_id"
  end

  add_index "chat_rooms", ["group_id"], :name => "index_chat_rooms_on_group_id"
  add_index "chat_rooms", ["leader_id"], :name => "index_chat_rooms_on_leader_id"
  add_index "chat_rooms", ["problem_owner_id"], :name => "index_chat_rooms_on_problem_owner_id"
  add_index "chat_rooms", ["supervision_id"], :name => "index_chat_rooms_on_supervision_id"

  create_table "feedbacks", :force => true do |t|
    t.string   "type"
    t.text     "content"
    t.integer  "supervision_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feedbacks", ["supervision_id"], :name => "index_feedbacks_on_supervision_id"
  add_index "feedbacks", ["user_id"], :name => "index_feedbacks_on_user_id"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "founder_id"
    t.string   "cached_slug"
    t.boolean  "closed",      :default => false
  end

  add_index "groups", ["founder_id"], :name => "index_groups_on_founder_id"

  create_table "ideas", :force => true do |t|
    t.integer  "supervision_id"
    t.integer  "user_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating"
  end

  add_index "ideas", ["supervision_id"], :name => "index_ideas_on_supervision_id"
  add_index "ideas", ["user_id"], :name => "index_ideas_on_user_id"

  create_table "memberships", :force => true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.string   "email"
  end

  add_index "memberships", ["group_id"], :name => "index_memberships_on_group_id"
  add_index "memberships", ["user_id"], :name => "index_memberships_on_user_id"

  create_table "questions", :force => true do |t|
    t.text     "content"
    t.integer  "user_id"
    t.integer  "supervision_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "questions", ["supervision_id"], :name => "index_questions_on_supervision_id"
  add_index "questions", ["user_id"], :name => "index_questions_on_user_id"

  create_table "slugs", :force => true do |t|
    t.string   "name"
    t.integer  "sluggable_id"
    t.integer  "sequence",                     :default => 1, :null => false
    t.string   "sluggable_type", :limit => 40
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "sequence", "scope"], :name => "index_slugs_on_n_s_s_and_s", :unique => true
  add_index "slugs", ["sluggable_id", "sluggable_type"], :name => "index_slugs_on_sluggable_id_and_sluggable_type"
  add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

  create_table "solutions", :force => true do |t|
    t.integer  "supervision_id"
    t.integer  "user_id"
    t.text     "content"
    t.integer  "rating"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "solutions", ["supervision_id"], :name => "index_solutions_on_supervision_id"
  add_index "solutions", ["user_id"], :name => "index_solutions_on_user_id"

  create_table "supervision_memberships", :force => true do |t|
    t.integer "supervision_id"
    t.integer "user_id"
  end

  add_index "supervision_memberships", ["supervision_id"], :name => "index_supervision_memberships_on_supervision_id"
  add_index "supervision_memberships", ["user_id"], :name => "index_supervision_memberships_on_user_id"

  create_table "supervisions", :force => true do |t|
    t.integer  "group_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "topic_id"
  end

  add_index "supervisions", ["group_id"], :name => "index_supervisions_on_group_id"
  add_index "supervisions", ["topic_id"], :name => "index_supervisions_on_topic_id"

  create_table "tolk_locales", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tolk_locales", ["name"], :name => "index_tolk_locales_on_name", :unique => true

  create_table "tolk_phrases", :force => true do |t|
    t.text     "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tolk_translations", :force => true do |t|
    t.integer  "phrase_id"
    t.integer  "locale_id"
    t.text     "text"
    t.text     "previous_text"
    t.boolean  "primary_updated", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tolk_translations", ["phrase_id", "locale_id"], :name => "index_tolk_translations_on_phrase_id_and_locale_id", :unique => true

  create_table "topics", :force => true do |t|
    t.integer  "supervision_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "topics", ["supervision_id"], :name => "index_topics_on_supervision_id"
  add_index "topics", ["user_id"], :name => "index_topics_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                                 :default => false
    t.boolean  "show_email",                            :default => false, :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "votes", :force => true do |t|
    t.integer  "statement_id"
    t.string   "statement_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["statement_id", "statement_type"], :name => "index_votes_on_statement_id_and_statement_type"
  add_index "votes", ["user_id"], :name => "index_votes_on_user_id"

end
