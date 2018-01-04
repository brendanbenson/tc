json.array! @result['numbers'] do |number|
  json.phone_number number['msisdn']
end