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

ActiveRecord::Schema.define(version: 2018_10_21_142625) do

  create_table "bots", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", limit: 50, default: "", null: false, collation: "utf8mb4_general_ci"
    t.string "channel_token", default: "", null: false
    t.string "channel_secret", limit: 250, default: "", null: false
    t.string "callback_hash", limit: 254, default: "", null: false
    t.timestamp "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamp "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.boolean "deleted", default: false, null: false
    t.timestamp "deleted_at"
    t.string "description", limit: 200
    t.boolean "notify", default: false, null: false
    t.index ["callback_hash"], name: "callback_hash", unique: true
  end

  create_table "converted_lineusers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "form_id", null: false
    t.integer "lineuser_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "datastores", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.binary "content", limit: 4294967295
  end

  create_table "forms", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "bot_id", null: false
    t.string "name", limit: 50
    t.string "describe_text"
    t.timestamp "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamp "updated_at", default: -> { "CURRENT_TIMESTAMP" }
    t.boolean "deleted", default: false, null: false
    t.boolean "is_active", default: false, null: false
    t.integer "first_reply_id"
  end

  create_table "lineusers", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "uid", limit: 100, default: "", null: false
    t.string "pictureUrl"
    t.string "name", limit: 50, default: "undefind"
    t.integer "bot_id", null: false
    t.timestamp "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamp "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.boolean "deleted", default: false, null: false
    t.integer "phase", default: 0, null: false
    t.boolean "is_unfollowed", default: false
    t.integer "lastmessage_id"
    t.integer "quick_reply_id"
    t.index ["uid"], name: "user_id", unique: true
  end

  create_table "logs", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "text", default: "", null: false
    t.integer "bot_id", null: false
    t.timestamp "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.boolean "deleted", default: false, null: false
  end

  create_table "messages", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.integer "lineuser_id", null: false
    t.string "content", default: "", null: false
    t.boolean "to_bot", null: false
    t.boolean "deleted", default: false, null: false
    t.timestamp "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamp "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "messages_used", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "content", default: "", null: false
    t.timestamp "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "user_id", limit: 200, default: "", null: false
    t.string "to_u", limit: 200, default: "", null: false
    t.boolean "deleted", default: false, null: false
    t.timestamp "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "notify_tokens", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "bot_id", null: false
    t.string "access_token", default: ""
    t.boolean "deleted", default: false, null: false
  end

  create_table "quick_replies", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "form_id", null: false
    t.string "name", limit: 50, default: "", null: false
    t.string "text", default: "", null: false
    t.string "describe_text", limit: 100, default: ""
    t.boolean "deleted", null: false
    t.integer "order_count", default: 0, null: false
    t.boolean "is_normal_message", default: true, null: false
    t.integer "next_reply_id"
  end

  create_table "quick_reply_items", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "quick_reply_id", null: false
    t.string "text", limit: 50, default: "", null: false
    t.boolean "deleted", default: false, null: false
    t.integer "next_reply_id"
  end

  create_table "remind_users", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "remind_id", null: false
    t.integer "lineuser_id", null: false
    t.boolean "deleted", default: false, null: false
  end

  create_table "reminds", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 100, default: "", null: false
    t.string "text"
    t.datetime "ignition_time"
    t.integer "bot_id", null: false
    t.boolean "deleted", default: false, null: false
    t.boolean "completed", default: false, null: false
    t.boolean "enable", default: true
    t.timestamp "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamp "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "response_data", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "lineuser_id", null: false
    t.integer "quick_reply_id", null: false
    t.string "response_text", limit: 11, default: "", null: false
    t.timestamp "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamp "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.boolean "deleted", default: false
  end

  create_table "session_lineusers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "form_id"
    t.integer "lineuser_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 50, default: "undefind", null: false
    t.timestamp "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamp "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "email", limit: 100, default: "", null: false
    t.string "password_digest", limit: 100, default: "", null: false
    t.string "remember_digest"
    t.boolean "deleted", default: false, null: false
  end

end
