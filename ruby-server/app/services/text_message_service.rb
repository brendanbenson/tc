class TextMessageService
  def self.send_text_message(text_message)
    ApplicationRecord.transaction do
      from_phone_number = '12109619091'
      from_contact = Contact.find_by!(phone_number: from_phone_number)
      text_message.from_contact = from_contact
      text_message.incoming = false
      text_message.save!

      response = client.send_message(
          from: from_phone_number,
          to: text_message.to_contact.phone_number,
          text: text_message.body
      )

      if response['messages'][0]['status'] == '0'
        puts "Sent message #{response['messages'][0]['message-id']}"
      else
        raise "Error: #{response['messages'][0]['error-text']}"
      end


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

  def self.client
    Nexmo::Client.new(key: ENV['NEXMO_KEY'], secret: ENV['NEXMO_SECRET'])
  end
end