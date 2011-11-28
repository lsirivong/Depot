require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  setup do
    @order = orders(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:orders)
  end

  test "should get new" do
    # put something in the cart first.
    cart = Cart.create
    session[:cart_id] = cart.id
    LineItem.create(:cart => cart, :product => products(:ruby))
    
    get :new
    assert_response :success
  end

  test "should create order" do
    assert_difference('Order.count') do
      post :create, order: @order.attributes
    end

    assert_redirected_to store_path
  end
  
  test "should email on create" do
    ActionMailer::Base.deliveries = []
    
    post :create, order: @order.attributes

    mail = ActionMailer::Base.deliveries.last
    assert_not_nil mail
    assert_equal "Pragmatic Store Order Confirmation", mail.subject
  end

  test "should show order" do
    get :show, id: @order.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @order.to_param
    assert_response :success
  end

  test "should update order" do
    put :update, id: @order.to_param, order: @order.attributes
    assert_redirected_to order_path(assigns(:order))
  end
  
  test "should email on update" do
    ActionMailer::Base.deliveries = []
    
    order = @order
    order.ship_date = DateTime.now

    
    put :update, id: order.to_param, order: order.attributes

    mail = ActionMailer::Base.deliveries.last
    assert_not_nil mail
    assert_equal "Pragmatic Store Order Shipped", mail.subject
  end

  test "should destroy order" do
    assert_difference('Order.count', -1) do
      delete :destroy, id: @order.to_param
    end

    assert_redirected_to orders_path
  end
  
  test "requires item in cart" do
    get :new
    assert_redirected_to store_path
    assert_equal flash[:notice], 'Your cart is empty'
  end
end
