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
  
  test "duplicate items should increment line_item quantity" do
    cart = Cart.new
    
    cart.add_product(products(:html).id)
    assert cart.save
    
    line_item = cart.add_product(products(:html).id)
    # this doesn't feel right, the first add_product will create and save
    # the line item, but the second one will modify but won't save the change
    # must save the returned line_item to work correctly
    assert line_item.save
    assert cart.save
    
    assert_equal 1, cart.line_items.count
    assert_equal 2, cart.total_items
  end
end
