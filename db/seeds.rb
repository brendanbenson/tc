Plan.create!(slug: 'free', conversation_messages: 3)
Plan.create!(slug: 'limited', conversation_messages: 250)
Plan.create!(slug: 'standard', conversation_messages: 500)
Plan.create!(slug: 'pro', conversation_messages: 2500)

denver_account = Account.create!
san_antonio_account = Account.create!
User.create!(email: "denver@example.com", password: "testing", account: denver_account)
User.create!(email: "sanantonio@example.com", password: "testing", account: san_antonio_account)

PhoneNumber.create!(number: "13033390054", account: denver_account)
PhoneNumber.create!(number: "12109619091", account: san_antonio_account)

Contact.create!(label: "Nexmo", account: denver_account, phone_number: "13033390054")
Contact.create!(label: "Nexmo", account: san_antonio_account, phone_number: "12109619091")

Contact.create!(label: "Brendan Benson", account: denver_account, phone_number: "12483429184")
Contact.create!(label: "Brendan Benson", account: san_antonio_account, phone_number: "12483429184")
