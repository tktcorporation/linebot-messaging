class AddPermissionCountToQuickReplySchedule < ActiveRecord::Migration[5.2]
  def change
    add_column :quick_reply_schedules, :permission_count, :integer, null: false, default: 1
  end
end
