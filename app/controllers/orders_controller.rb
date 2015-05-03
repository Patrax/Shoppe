class OrdersController < ApplicationController
  
  def checkout
    @order = Shoppe::Order.find(current_order.id)
    if request.patch?
      if @order.proceed_to_confirm(order_params)
        redirect_to checkout_payment_path
      end
    end
  end
  
  def payment
    if request.post?
      redirect_to checkout_confirmation_path
    end
  end
  
  def confirmation
    if request.post?
      current_order.confirm!
      session[:order_id] = nil
      flash[:success] = "Order has been placed successfully!"
      redirect_to root_path
    end
  end
  
  def paypal
    @order = Shoppe::Order.find(session[:current_order_id])
    url = @order.redirect_to_paypal(checkout_payment_url(success: true), checkout_payment_url(success: false))
    redirect_to url
  end
  
  def destroy
    current_order.destroy
    session[:order_id] = nil
    flash[:success] = "Basket emptied successfully."
    redirect_to root_path
  end
  
  private
  
    def order_params
      params[:order].permit(  :first_name, :last_name, :billing_address1,
                              :billing_address2, :billing_address3, :billing_address4,
                              :billing_country_id, :billing_postcode, :email_address,
                              :phone_number)
    end
  
end
