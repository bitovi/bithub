json.(billing, :id, :description, :period_beginning, :period_end, :total, :currency)

json.set! :records do
  json.array! billing.monthly_billing_records do |r|
    json.partial! "api/v3/monthly_billing_records/monthly_billing_record", record: r
  end
end