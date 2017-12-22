class Api::ContactsController < ApplicationController
  def index
    if params[:q].present?
      @contacts = Contact.search(params[:q])
    else
      @contacts = Contact.all
    end
  end

  def create
    # TODO: validate phone number via Twilio
    @contact = Contact.create!(phone_number: params[:phoneNumber], label: params[:label])
  end

  def update
    @contact = Contact.find(params[:id])

    @contact.update_attributes!(label: params[:label], phone_number: params[:phoneNumber])
  end
end