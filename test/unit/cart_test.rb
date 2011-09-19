require 'test_helper'

class CartTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  test "cart should be added" do
    cart = Cart.new
    assert cart.valid?
    
    assert cart.save
  end
  
  test "cart should add product" do
    cart = Cart.new
    assert cart.save
    
    assert_equal 0, cart.line_items.count
    
    line_item = cart.add_product(products(:ruby).id)
    assert cart.save
    
    assert_equal 1, line_item.quantity
    assert_equal 1, cart.line_items.count
  end
  
  test "duplicate items should increment quantity" do
    cart = Cart.new
    
    cart.add_product(products(:ruby).id)
    assert cart.save
    
    line_item = cart.add_product(products(:ruby).id)
    assert cart.save
    
    assert_equal 2, line_item.quantity
    assert_equal 1, cart.line_items.count
  end
end
