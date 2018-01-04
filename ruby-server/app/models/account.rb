class Account < ApplicationRecord
  has_many :user_accounts
  has_many :users

  has_one :phone_number
end