class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> { request.format.json? }

  before_action :authenticate_user!

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
end
