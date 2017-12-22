class ContactGroup < ApplicationRecord
  self.table_name = 'contacts_groups'
  belongs_to :contact
  belongs_to :group
end