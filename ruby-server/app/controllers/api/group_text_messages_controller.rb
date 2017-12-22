class Api::GroupTextMessagesController < ApplicationController
  def index
    @group_text_messages = Group.find(params[:group_id]).group_text_messages
  end

  def create
    group = Group.find(params[:group_id])
    @group_text_message = GroupTextMessage.new(body: params[:body], group: group)

    TextMessageService.send_group_text_message(group_text_message)
  end
end