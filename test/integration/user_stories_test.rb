require 'test_helper'

class UserStoriesTest < ActionDispatch::IntegrationTest
  fixtures :products
  
  test "buying a product" do
    LineItem.delete_all
    Order.delete_all
    ruby_book = products(:ruby)
  
    # "A user ges to the store index page"
    get "/"
    assert_response :success
    assert_template "index"
  
    # "They select a product, adding it to their cart"
    xml_http_request :post, '/line_items', :product_id => ruby_book.id
    assert_response :success
  
    cart = Cart.find(session[:cart_id])
    assert_equal 1, cart.line_items.size
    assert_equal ruby_book, cart.line_items[0].product
  
    # "They then check out..."
    get "/orders/new"
    assert_response :success
    assert_template "new"
  
    # post form data to the save_order action
    post_via_redirect "/orders",
                      :order => { :name      => "Dave Thomas",
                                 :address   => "123 The Street",
                                 :email     => "dave@example.com",
                                 :pay_type  => "Check" }
    assert_response :success
    assert_template "index"
    cart = Cart.find(session[:cart_id])
    assert_equal 0, cart.line_items.size
  
    # make sure order and line item created as expected
    orders = Order.all
    assert_equal 1, orders.size
    order = orders[0]
  
    assert_equal "Dave Thomas",       order.name
    assert_equal "123 The Street",    order.address
    assert_equal "dave@example.com",  order.email
    assert_equal "Check",             order.pay_type
  
    assert_equal 1, order.line_items.size
    line_item = order.line_items[0]
    assert_equal ruby_book, line_item.product
  
    # correctly addressed and expected subject line
    mail = ActionMailer::Base.deliveries.last
    assert_equal ["dave@example.com"], mail.to
    assert_equal 'Sam Ruby <depot@example.com>', mail[:from].value
    assert_equal "Pragmatic Store Order Confirmation", mail.subject
  end
  # 
  # test "updating an order" do
  #   ActionMailer::Base.deliveries = []
  #   LineItem.delete_all
  #   Order.delete_all
  #   ruby_book = products(:ruby)
  # 
  #   # "A user goes to the store index page"
  #   get "/"
  #   assert_response :success
  #   assert_template "index"
  # 
  #   # "They select a product, adding it to their cart"
  #   xml_http_request :post, '/line_items', :product_id => ruby_book.id
  #   assert_response :success
  # 
  #   cart = Cart.find(session[:cart_id])
  #   assert_equal 1, cart.line_items.size
  #   assert_equal ruby_book, cart.line_items[0].product
  # 
  #   # "They then check out..."
  #   get "/orders/new"
  #   assert_response :success
  #   assert_template "new"
  # 
  #   # post form data to the save_order action
  #   post_via_redirect "/orders",
  #                     :order => { :name      => "Dave Thomas",
  #                                :address   => "123 The Street",
  #                                :email     => "dave@example.com",
  #                                :pay_type  => "Check" }
  #   assert_response :success
  #   assert_template "index"
  #   cart = Cart.find(session[:cart_id])
  #   assert_equal 0, cart.line_items.size
  #   
  #   ActionMailer::Base.deliveries = []
  # 
  #   # make sure order and line item created as expected
  #   orders = Order.all
  #   assert_equal 1, orders.size
  #   order = orders[0]
  # 
  #   assert_equal "Dave Thomas",       order.name
  #   assert_equal "123 The Street",    order.address
  #   assert_equal "dave@example.com",  order.email
  #   assert_equal "Check",             order.pay_type
  # 
  #   assert_equal 1, order.line_items.size
  #   line_item = order.line_items[0]
  #   assert_equal ruby_book, line_item.product
  #     
  #   now = DateTime.now
  #   order.ship_date = now
  #   put_via_redirect order_path(order), order: order.attributes
  #   
  #   assert_response :success
  #   
  #   mail = ActionMailer::Base.deliveries.last
  #   assert_not_nil mail
  #   assert_equal ["dave@example.com"], mail.to
  #   assert_equal 'Sam Ruby <depot@example.com>', mail[:from].value
  #   assert_equal "Pragmatic Store Order Shipped", mail.subject
  # end
  # 
  # test "show a cart that does not exist" do 
  #   LineItem.delete_all
  #   Order.delete_all
  #   Cart.delete_all
  # 
  #   assert_equal 0, Cart.all.count
  #   
  #   get "/carts/1337"
  #   
  #   mail = ActionMailer::Base.deliveries.last
  #   assert_equal ["depot_admin@example.com"], mail.to
  #   assert_equal 'Sam Ruby <depot@example.com>', mail[:from].value
  #   assert_equal "Admin Notification: Pragmatic Store Error Occurred", mail.subject
  # end
  
  test "login when no users exist" do    
    User.delete_all
    assert User.all.empty?
    
    get "/login"
    assert_response :success
    
    post_via_redirect "/login",
      :user => { :name => "doesnotexistent", :password => "anything" }
    assert_response :success
    
    assert_equal "/admin", path
  end
end
