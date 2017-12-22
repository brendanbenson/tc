class TextMessage < ApplicationRecord
  belongs_to :to_contact, class_name: "Contact", foreign_key: "to_contact_id"
  belongs_to :from_contact, class_name: "Contact", foreign_key: "from_contact_id"

  def self.for_to_or_from_contact(contact)
    where(from_contact: contact).or(where(to_contact: contact))
  end

  def self.latest_threads
    sql = <<SQL
SELECT m1.*
FROM
  text_messages m1
  LEFT JOIN text_messages m2
    ON (m1.to_contact_id = m2.to_contact_id
        AND m1.created_at < m2.created_at)
WHERE m2.id IS NULL
ORDER BY m1.created_at DESC
SQL
    find_by_sql(sql)
  end
end