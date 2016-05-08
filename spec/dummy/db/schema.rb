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

ActiveRecord::Schema.define(:version => 20160507154801) do

  create_table "exception_canary_comments", :force => true do |t|
    t.string   "commentable_type",              :null => false
    t.integer  "commentable_id",   :limit => 8, :null => false
    t.text     "body"
    t.integer  "user_id",          :limit => 8
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "exception_canary_comments", ["commentable_id", "commentable_type"], :name => "index_exception_canary_comments_on_commentable"

  create_table "exception_canary_groups", :force => true do |t|
    t.string   "fingerprint",         :null => false
    t.text     "name"
    t.integer  "notification_action"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "exception_canary_groups", ["fingerprint"], :name => "index_exception_canary_groups_on_fingerprint"

  create_table "exception_canary_stored_exceptions", :force => true do |t|
    t.integer  "group_id",        :limit => 8, :null => false
    t.string   "fingerprint",                  :null => false
    t.text     "message"
    t.string   "exception_class"
    t.text     "backtrace"
    t.text     "environment"
    t.text     "variables"
    t.integer  "user_id",         :limit => 8
    t.string   "ip_address"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "exception_canary_stored_exceptions", ["fingerprint"], :name => "index_exception_canary_stored_exceptions_on_fingerprint"
  add_index "exception_canary_stored_exceptions", ["group_id"], :name => "index_exception_canary_stored_exceptions_on_group_id"

end
