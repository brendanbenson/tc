class TextMessageService
  def self.send_text_message(text_message)
    ApplicationRecord.transaction do
      from_phone_number = "+14194914157"
      from_contact = Contact.find_by!(phone_number: from_phone_number)
      text_message.from_contact = from_contact
      text_message.incoming = false
      text_message.save!

      twilio_client.api.account.messages.create(
          from: text_message.from_contact.phone_number,
          to: text_message.to_contact.phone_number,
          body: text_message.body
      )

      text_message.update_attributes!(delivered_at: Time.now)
    end

    text_message
  end

  def self.send_group_text_message(group_text_message)
    group_text_message
        .group
        .contacts
        .map { |c| send_text_message(TextMessage.new(to_contact: c, body: group_text_message.body)) }
  end

  def self.record_receipt(from_phone_number, to_phone_number, body)
    from_contact = Contact.find_or_create_by!(phone_number: from_phone_number)
    to_contact = Contact.find_by!(phone_number: to_phone_number)

    TextMessage.create!(
        body: body,
        incoming: true,
        to_contact: to_contact,
        from_contact: from_contact,
        delivered_at: Time.now
    )
  end

  def self.twilio_client
    account_sid = 'ACa14c8ca7319e9e69093cc7dce6b0fb87'
    auth_token = 'af82f2a7708264f8ef875d3a54479eb7'

    # TODO: make this more dependency-injection-ish or abstracted
    Twilio::REST::Client.new account_sid, auth_token
  end
end