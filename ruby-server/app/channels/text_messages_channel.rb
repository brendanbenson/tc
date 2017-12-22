class TextMessagesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "text_messages"
  end
end