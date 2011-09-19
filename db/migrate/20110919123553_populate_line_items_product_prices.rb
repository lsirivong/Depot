class PopulateLineItemsProductPrices < ActiveRecord::Migration
  def up
    LineItem.all.each do |line_item|
      line_item.product_price = line_item.product.price
      line_item.save
    end
  end

  def down
    LineItem.all.each do |line_item|
      line_item.product_price = nil
      line_item.save
    end
  end
end
