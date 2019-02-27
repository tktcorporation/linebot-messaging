class CreateBotCheckNotificationQuickReply < ActiveRecord::Migration[5.2]
  def change
    create_table :bot_check_notification_quick_replies, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :check_notification_id, foreign_key: true
      t.integer :quick_reply_id, foreign_key: true

      t.timestamps
    end
  end
end
