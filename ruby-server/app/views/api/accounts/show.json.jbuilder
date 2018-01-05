json.account @account, partial: 'account', as: :account
json.users @account.users, partial: 'api/users/user', as: :user