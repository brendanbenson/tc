json.textMessages @text_messages, partial: 'text_message', as: :text_message
json.contacts @contacts, partial: 'api/contacts/contact', as: :contact