class CreateBotCheckNotification < ActiveRecord::Migration[5.2]
  def change
    create_table :bot_check_notifications, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :bot_id, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end
  end
end
