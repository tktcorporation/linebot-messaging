class AddIsClosedToLineusers < ActiveRecord::Migration[5.2]
  def change
    add_column :lineusers, :is_closed, :boolean, null: false, default: false
  end
end
