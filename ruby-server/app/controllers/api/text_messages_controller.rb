class Api::TextMessagesController < ApplicationController
  include ChannelHelper

  skip_before_action :authenticate_user!, only: :receive

  def index
    if params[:contact_id].present?
      contact = Contact.find(params[:contact_id])
      @text_messages = TextMessage.for_to_or_from_contact(contact).order(created_at: :desc)
      return render :contact_index
    end

    @text_messages = TextMessage.includes(:to_contact, :from_contact).latest_threads
    @contacts = @text_messages.map(&:to_contact) + @text_messages.map(&:from_contact)
  end

  def create
    to_contact = Contact.find(params[:contact_id])
    @text_message = TextMessage.new(
        body: params[:body],
        to_contact: to_contact
    )
    TextMessageService.send_text_message(@text_message)
    broadcast_text_messages [@text_message]
  end

  # TODO: add some security here so random people can't hit this endpoint
  def receive
    text_message = TextMessageService.record_receipt(params["msisdn"], params["to"], params["text"])
    broadcast_text_messages [text_message]
  end
end