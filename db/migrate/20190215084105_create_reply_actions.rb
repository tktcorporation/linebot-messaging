class CreateReplyActions < ActiveRecord::Migration[5.2]
  def change
    create_table :bot_reply_actions, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :quick_reply_id, foreign_key: true
      t.integer :bot_id, foreign_key: true
      t.string :name, null: false
      t.string :text, null: false
      t.boolean :is_active, default: 1

      t.timestamps
    end
  end
end