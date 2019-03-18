class CreateStockImages < ActiveRecord::Migration[5.2]
  def change
    create_table :stock_images, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :bot_id, foreign_key: true
      t.string :image

      t.timestamps
    end
  end
end
