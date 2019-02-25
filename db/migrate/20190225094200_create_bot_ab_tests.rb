class CreateBotAbTests < ActiveRecord::Migration[5.2]
  def change
    create_table :bot_ab_tests, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :bot_id, foreign_key: true
      t.string :name, null: false
      t.boolean :is_active, default: 0

      t.timestamps
    end
  end
end
