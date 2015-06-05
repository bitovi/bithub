json.set! :data do
  json.array! @billings do |b|
    json.partial! "api/v3/monthly_billings/monthly_billing", billing: b
  end
end
