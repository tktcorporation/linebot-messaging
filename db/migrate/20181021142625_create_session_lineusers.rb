class CreateSessionLineusers < ActiveRecord::Migration[5.2]
  def change
    create_table :session_lineusers do |t|
      t.integer :form_id
      t.integer :lineuser_id

      t.timestamps
    end
  end
end
