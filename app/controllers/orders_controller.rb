class OrdersController < ApplicationController
  skip_before_filter :authorize, :only => [:new, :create]
  
  def get_type_names
    PaymentType.names
  end
  
  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.paginate :page=>params[:page], :order=>'created_at desc',
      :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @orders }
    end
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @order = Order.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @order }
    end
  end

  # GET /orders/new
  # GET /orders/new.json
  def new
    @cart = current_cart
    @type_names = get_type_names
    
    if @cart.line_items.empty?
      redirect_to store_url, :notice => "Your cart is empty"
      return
    end
    
    @order = Order.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @order }
    end
  end

  # GET /orders/1/edit
  def edit
    @order = Order.find(params[:id])
    @type_names = get_type_names
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(params[:order])
    @type_names = get_type_names
    @order.add_line_items_from_cart(current_cart)

    respond_to do |format|
      if @order.save
        Cart.destroy(session[:cart_id])
        session[:cart_id] = nil
        Notifier.order_received(@order).deliver
        format.html { redirect_to(store_url, :notice =>
          I18n.t('.thanks')) }
        format.json { render json: @order, status: :created, location: @order }
      else
        format.html { render action: "new" }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /orders/1
  # PUT /orders/1.json
  def update
    @order = Order.find(params[:id])
    @type_names = get_type_names

    respond_to do |format|
      old_ship_date = @order.ship_date
      if @order.update_attributes(params[:order])
        # if ((!@order.ship_date.nil?) && (old_ship_date != @order.ship_date))
          Notifier.order_shipped(@order).deliver
        # end
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order = Order.find(params[:id])
    @order.destroy

    respond_to do |format|
      format.html { redirect_to orders_url }
      format.json { head :ok }
    end
  end
end
