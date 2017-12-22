class Api::TextMessagesController < ApplicationController
  include ChannelHelper

  def index
    if params[:contact_id].present?
      contact = Contact.find(params[:contact_id])
      @text_messages = TextMessage.for_to_or_from_contact(contact).order(created_at: :desc)
      broadcast_text_messages
      return render :contact_index
    end

    @text_messages = TextMessage.includes(:to_contact, :from_contact).latest_threads
    @contacts = @text_messages.map(&:to_contact) + @text_messages.map(&:from_contact)
  end

  def create
    to_contact = Contact.find(params[:contact_id])
    # TODO: make it not save yet
    @text_message = TextMessage.create!(
        body: params[:body],
        to_contact: to_contact,
        from_contact: Contact.first,
        incoming: false
    )
    TextMessageService.send(@text_message)
    broadcast_text_messages
  end

  # TODO: add some security here so random people can't hit this endpoint
  def receive
    TextMessageService.record_receipt(params["From"], params["To"], params["Body"])
    broadcast_text_messages
  end

  private

  def broadcast_text_messages
    # TODO: only broadcast the right data
    broadcast(
        "text_messages",
        render_json(
            template: 'api/text_messages/broadcast',
            locals: {text_messages: TextMessage.all.to_a, contacts: Contact.all.to_a}
        )
    )
  end
end