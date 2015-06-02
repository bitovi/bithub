module MonthlyBillings
  class Manager

    def initialize(org_id, embed_events_logs, opts={})
      _year    = opts.fetch(:year) { Time.now.year }
      _month   = opts.fetch(:month) { Time.now.month }

      @org_id  = org_id
      @ee_logs = embed_events_logs
      @month   = Time.new _year, _month
      @price   = opts.fetch(:price) { ENV['EMBED_PRICE_PER_DAY'] }
    end

    def save_to_monthly_billings!
      @mb = MonthlyBilling.new\
        organization_id: @org_id,
        period_beginning: @month.beginning_of_month,
        period_end: @month.end_of_month,
        total: 0

      @mb.save!

      sum_up_usage_per_days.each do |key, dates|
        brand_id, embed_id = key
        last_date   =  dates.map {|d| d}.last
        last_rec    = find_record(brand_id, embed_id, last_date)
        description = "Hub '#{last_rec.embed_name}' from brand '#{last_rec.brand_name}'"

        @mb.total += dates.count * @price
        @mb.monthly_billing_records << MonthlyBillingRecord.new(description: description, amount: dates.count, price: @price)
      end

      @mb.save!
    end

    def sum_up_usage_per_days
      @ee_logs.reduce(Hash.new(Set.new([]))) do |acc, rec|
        key = [rec.brand_id, rec.embed_id]

        # skip if there is next in month or use end of the month
        if rec.active == true
          if !next_in_month(rec)
            acc[key] += dayspan(rec.date, @month.end_of_month)
          end
        end

        # find previous and add dayspan or use beginning of the month
        if rec.active == false
          if beginning = previous_in_month(rec)
            acc[key] += dayspan(beginning.date, rec.date)
          else
            acc[key] += dayspan(@month.beginning_of_month, rec.date)
          end
        end

        acc
      end
    end

    private

    def find_record(brand_id, embed_id, date)
      @ee_logs.select {|r| r.brand_id == brand_id && r.embed_id == r.embed_id && r.date = date}.last
    end

    def dayspan(_beginning, _end)
      (_beginning.to_date.._end.to_date).map {|d| d}
    end

    def previous_in_month(rec)
      @ee_logs\
        .select {|r| r.brand_id == rec.brand_id && r.embed_id == rec.embed_id && r.date < rec.date}
        .last
    end

    def next_in_month(rec)
      @ee_logs\
        .select {|r| r.brand_id == rec.brand_id && r.embed_id == rec.embed_id && r.date > rec.date}
        .first
    end

  end
end
