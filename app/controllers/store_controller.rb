class StoreController < ApplicationController
  skip_before_filter :authorize
  def index
    @products = Product.all
    @cart = current_cart
    
    session[:index_access_count] ||= 0
    session[:index_access_count] += 1
    @index_access_count = session[:index_access_count]
  end
end
