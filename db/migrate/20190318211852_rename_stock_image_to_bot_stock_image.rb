class RenameStockImageToBotStockImage < ActiveRecord::Migration[5.2]
  def change
    rename_table :stock_images, :bot_stock_images
  end
end
