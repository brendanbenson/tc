class Api::AccountsController < ApplicationController
  def show
    @account = current_account
  end
end