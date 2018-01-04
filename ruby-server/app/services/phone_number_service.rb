class PhoneNumberService
  def self.search(q)
    client.get_available_numbers('US', pattern: "^1#{q}", size: 20)
  end

  def self.buy(account, number)
    ActiveRecord::Base.transaction do
      PhoneNumber.create!(account: account, number: number)
      Contact.create!(label: "", phone_number: number)
      client.buy_number(country: 'US', msisdn: number)
    end
  end

  def self.client
    Nexmo::Client.new(key: ENV['NEXMO_KEY'], secret: ENV['NEXMO_SECRET'])
  end
end