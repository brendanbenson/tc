class Contact < ApplicationRecord
  has_many :contact_groups
  has_many :groups, through: :contact_groups

  def self.search(q)
    sql = <<-SQL
SELECT *
FROM contacts c
WHERE lower(c.label)
      LIKE lower(CONCAT('%', :q, '%'))
      OR lower(c.phone_number) LIKE CONCAT('%', :q, '%')
    SQL

    find_by_sql [sql, q: q]
  end
end