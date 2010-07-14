# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 9) do

  create_table "attachments", :force => true do |t|
    t.integer  "ticket_text_id"
    t.string   "mime_type"
    t.binary   "data"
    t.datetime "created_at"
  end

  create_table "categories", :force => true do |t|
    t.string  "name"
    t.string  "parent"
    t.integer "user_selectable", :default => 1
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "settings", :force => true do |t|
    t.string "name"
    t.string "value"
  end

  create_table "ticketlogs", :force => true do |t|
    t.integer  "ticket_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.string   "log_type"
    t.text     "log"
  end

  create_table "tickets", :force => true do |t|
    t.string   "subject"
    t.integer  "ticketstatus_id"
    t.integer  "category_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticketstatuses", :force => true do |t|
    t.string  "name"
    t.string  "status_type"
    t.integer "user_selectable"
  end

  create_table "tickettexts", :force => true do |t|
    t.integer  "ticket_id"
    t.string   "post_type"
    t.integer  "user_id"
    t.text     "text_content"
    t.datetime "created_at"
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.integer  "type_id"
    t.string   "password_hash"
    t.string   "salt"
    t.string   "phone_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "footer"
  end

end
