class GroupTextMessage < ApplicationRecord
  belongs_to :account
  belongs_to :user
  belongs_to :group
end