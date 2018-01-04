class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> { request.format.json? }

  before_action :authenticate_user!

  def index
    if current_account.blank?
      current_user.create_account!
      current_user.save!
    end

    if current_account.phone_number.blank?
      redirect_to new_phone_number_path
    end
  end

  def broadcast_text_messages(text_messages)
    broadcast(
        "text_messages",
        render_json(
            template: 'api/text_messages/broadcast',
            locals: {
                text_messages: text_messages,
                contacts: text_messages.flat_map(&:to_contact).uniq + text_messages.flat_map(&:from_contact).uniq
            }
        )
    )
  end

  def current_account
    current_user.account
  end

  def current_contact
    Contact.find_by!(phone_number: current_account.phone_number.number)
  end
end
