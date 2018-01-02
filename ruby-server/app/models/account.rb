class Account < ApplicationRecord
  has_many :user_accounts
  has_many :users

  has_many :phone_numbers
end