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

ActiveRecord::Schema.define(version: 2019_03_18_172808) do

  create_table "active_storage_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "bot_ab_test_forms", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "ab_test_id"
    t.integer "form_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bot_ab_tests", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "bot_id"
    t.string "name", null: false
    t.boolean "is_active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bot_check_notification_quick_replies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "check_notification_id"
    t.integer "quick_reply_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bot_check_notifications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "bot_id"
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_active", default: true, null: false
  end

  create_table "bot_lineuser_statuses", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "lineuser_id", null: false
    t.integer "status_id"
  end

  create_table "bot_reply_actions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "quick_reply_id"
    t.integer "bot_id"
    t.string "name", null: false
    t.string "text", null: false
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bot_slack_api_sets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "bot_id"
    t.string "webhook_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bot_statuses", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "bot_id", null: false
    t.string "name", limit: 50, default: "", null: false
    t.boolean "deleted", null: false
  end

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

  create_table "google_api_sets", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "access_token"
    t.string "scope", default: "https://www.googleapis.com/auth/calendar", null: false
    t.string "token_type", limit: 100
    t.string "refresh_token"
    t.integer "expires_in"
    t.integer "bot_id"
    t.timestamp "created_at", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamp "updated_at"
    t.string "email"
    t.string "client_secret"
    t.string "client_id"
  end

  create_table "lineuser_invitation_codes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "lineuser_id"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lineusers", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "uid", limit: 100, default: "", null: false, collation: "utf8_general_ci"
    t.string "pictureUrl", collation: "utf8_general_ci"
    t.string "name", limit: 60, default: "undefind"
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
    t.text "text", null: false, collation: "utf8mb4_general_ci"
    t.integer "bot_id", null: false
    t.timestamp "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.boolean "deleted", default: false, null: false
  end

  create_table "messages", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.integer "lineuser_id", null: false
    t.text "content", null: false
    t.boolean "to_bot", null: false
    t.integer "msg_type", default: 0, null: false
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
    t.text "text", null: false, collation: "utf8mb4_general_ci"
    t.string "describe_text", limit: 100, default: ""
    t.boolean "deleted", default: false
    t.integer "order_count", default: 0
    t.boolean "is_normal_message", default: true
    t.integer "next_reply_id"
    t.integer "reply_type", default: 0, comment: "0:普通のメッセージ、1:質問メッセージ、2:自由入力質問、3:スケジュール調整"
  end

  create_table "quick_reply_items", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "quick_reply_id", null: false
    t.string "text", limit: 50, default: "", null: false
    t.boolean "deleted", default: false, null: false
    t.integer "next_reply_id"
  end

  create_table "quick_reply_schedules", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "quick_reply_id", null: false
    t.integer "duration_days", null: false
    t.string "summary", default: "", null: false
    t.string "description_text"
    t.string "available_day", limit: 7, default: "", null: false
    t.integer "duration_num"
    t.integer "start_num"
    t.integer "term_num", comment: "1~12"
    t.integer "permission_count", default: 1, null: false
  end

  create_table "quick_reply_text_flags", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "quick_reply_text_id", null: false
    t.integer "lineuser_id", null: false
    t.boolean "is_accepting", default: true, null: false
  end

  create_table "quick_reply_texts", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "quick_reply_id", null: false
    t.integer "text_type"
  end

  create_table "remind_users", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "remind_id", null: false
    t.integer "lineuser_id", null: false
    t.boolean "deleted", default: false, null: false
  end

  create_table "reminds", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 100, default: "", null: false
    t.string "text", default: "", null: false
    t.datetime "ignition_time", null: false
    t.integer "bot_id", null: false
    t.boolean "deleted", default: false, null: false
    t.boolean "completed", default: false, null: false
    t.boolean "enable", default: true, null: false
    t.timestamp "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamp "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "response_data", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "lineuser_id", null: false
    t.integer "quick_reply_id", null: false
    t.string "response_text", default: "", null: false, collation: "utf8mb4_general_ci"
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

  create_table "stock_images", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "bot_id"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 50, default: "undefind", null: false
    t.timestamp "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamp "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "email", limit: 100, default: "", null: false
    t.string "password_digest", limit: 100, default: "", null: false, collation: "utf8_bin"
    t.string "remember_digest", default: "", collation: "utf8_bin"
    t.boolean "deleted", default: false, null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
end
