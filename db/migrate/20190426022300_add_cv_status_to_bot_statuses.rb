class AddCvStatusToBotStatuses < ActiveRecord::Migration[5.2]
  def change
    add_column :bot_statuses, :is_cv_status, :boolean, null: false, default: false
  end
end
