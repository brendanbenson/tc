class Api::GroupTextMessagesController < ApplicationController
  def index
    @group_text_messages = Group.find(params[:group_id]).group_text_messages
  end

  def create
    group = Group.find(params[:group_id])
    @group_text_message = GroupTextMessage.create!(body: params[:body], group: group)

    text_messages = TextMessageService.send_group_text_message(@group_text_message)

    broadcast_text_messages text_messages
  end
end