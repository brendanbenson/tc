class Contact < ApplicationRecord
  belongs_to :account
  has_many :contact_groups
  has_many :groups, through: :contact_groups

  def self.search(account, q)
    sql = <<-SQL
SELECT *
FROM contacts c
WHERE 
  c.account_id = :account_id AND
      (lower(c.label)
      LIKE lower(CONCAT('%', :q, '%'))
      OR lower(c.phone_number) LIKE CONCAT('%', :q, '%'))
    SQL

    find_by_sql [sql, q: q, account_id: account.id]
  end
end