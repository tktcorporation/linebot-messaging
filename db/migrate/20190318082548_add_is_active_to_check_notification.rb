class AddIsActiveToCheckNotification < ActiveRecord::Migration[5.2]
  def change
    add_column :bot_check_notifications, :is_active, :boolean, null: false, default: 1
  end
end
