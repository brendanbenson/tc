class TextMessagesChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user.account
  end
end