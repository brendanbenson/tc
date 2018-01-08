class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> { request.format.json? }

  before_action :authenticate_user!

  rescue_from Validation::Error, :with => :render_validation_errors

  def render_validation_errors(exception)
    render json: exception.errors.to_json, status: 400
  end

  def index
    if current_account.blank?
      current_user.create_account!
      current_user.save!
    end

    if current_account.plan.blank?
      redirect_to plans_path
    end

    if current_account.phone_number.blank?
      redirect_to new_phone_number_path
    end
  end

  def broadcast_text_messages(text_messages)
    text_messages.each do |text_message|
      TextMessagesChannel.broadcast_to(
          text_message.account,
          render_json(
              template: 'api/text_messages/broadcast',
              locals: {
                  text_messages: [text_message],
                  contacts: [text_message.from_contact, text_message.to_contact]
              }
          )
      )
    end
  end

  def current_account
    current_user.account
  end

  def current_contact
    Contact.find_by!(phone_number: current_account.phone_number.number)
  end
end
