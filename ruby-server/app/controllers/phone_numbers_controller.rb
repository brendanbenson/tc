class PhoneNumbersController < ApplicationController
  def new
    if params[:q]
      @results = PhoneNumberService.search(params[:q])
    end
  end

  def create
    PhoneNumberService.buy(current_account, params[:number])
    redirect_to root_path
  end
end