class StoreController < ApplicationController
  skip_before_filter :authorize
  def index
    if params[:set_locale]
      redirect_to store_path(:locale => params[:set_locale])
    else
      @products = Product.all
      @cart = current_cart
    end
    
    session[:index_access_count] ||= 0
    session[:index_access_count] += 1
    @index_access_count = session[:index_access_count]
  end
end
