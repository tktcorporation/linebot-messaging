class AddIsTemplateToForms < ActiveRecord::Migration[5.2]
  def change
    add_column :forms, :is_template, :boolean, null: false, default: false
  end
end
