class Group < ApplicationRecord
  belongs_to :account
  has_many :group_text_messages
  has_many :contact_groups
  has_many :contacts, through: :contact_groups

  def self.search(q)
    sql = <<SQL
SELECT *
FROM groups g
WHERE lower(g.label) LIKE lower(CONCAT('%', :q, '%'))
ORDER BY g.label;
SQL
    find_by_sql [sql, q: q]
  end
end