class Account < ApplicationRecord
  has_many :users

  has_one :phone_number
end