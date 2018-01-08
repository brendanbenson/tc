class PhoneNumbersController < ApplicationController
  def new
    if current_account.phone_number.present?
      redirect_to root_path
    end

    if params[:q]
      @results = PhoneNumberService.search(params[:q])
    end
  end

  def create
    PhoneNumberService.buy(current_account, params[:number])
    flash[:notice] = "Your number has been selected"
    redirect_to root_path
  end
end