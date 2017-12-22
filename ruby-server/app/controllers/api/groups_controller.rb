class Api::GroupsController < ApplicationController
  def show
    @group = Group.find(params[:id])
  end

  def suggest
    existing_groups = Contact.find(params[:contact_id]).groups
    @groups = Group.search(params[:q])
                  .select { |g| !existing_groups.include? g }
  end

  def contacts
    group = Group.find(params[:group_id])
    @contacts = group.contacts.order(:label, :phone_number)
  end

  def suggest_contacts
    existing_contacts = Group.find(params[:group_id]).contacts

    @contacts = Contact
        .search(params[:q])
        .select { |c| !existing_contacts.include? c}
  end

  def create
    contact = Contact.find(params[:contact_id])
    @group = Group.find(params[:groupId])
    ContactGroup.create!(contact: contact, group: @group)
  end

  def destroy
    @group = Group.find(params[:id])
    ContactGroup.find_by(contact_id: params[:contact_id], group: @group).destroy!
  end
end