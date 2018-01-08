class Account < ApplicationRecord
  has_many :users
  has_one :phone_number
  belongs_to :plan, optional: true
  has_many :text_messages

  def can_send_text_message?
    text_messages.within_this_month.count < plan.conversation_messages
  end
end