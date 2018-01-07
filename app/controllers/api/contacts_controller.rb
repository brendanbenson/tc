class Api::ContactsController < ApplicationController
  def index
    if params[:q].present?
      @contacts = Contact.search(current_account, params[:q])
    else
      @contacts = Contact.where(account: current_account)
    end
  end

  def create
    # TODO: validate phone number via Twilio
    @contact = Contact.create!(
        phone_number: params[:phoneNumber],
        label: params[:label],
        account: current_account
    )
  end

  def update
    @contact = Contact.where(account: current_account).find(params[:id])

    @contact.update_attributes!(label: params[:label], phone_number: params[:phoneNumber])
  end
end