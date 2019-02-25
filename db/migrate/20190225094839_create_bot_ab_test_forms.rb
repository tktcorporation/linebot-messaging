class CreateBotAbTestForms < ActiveRecord::Migration[5.2]
  def change
    create_table :bot_ab_test_forms, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :ab_test_id, foreign_key: true
      t.integer :form_id, foreign_key: true

      t.timestamps
    end
  end
end
