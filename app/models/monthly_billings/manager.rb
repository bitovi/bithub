module MonthlyBillings
  class Manager

    attr_reader :price, :month, :ee_logs

    def initialize(org_id, embed_events_logs, opts={})
      _year    = opts.fetch(:year) { Time.now.year }
      _month   = opts.fetch(:month) { Time.now.month }

      @org_id  = org_id
      @ee_logs = embed_events_logs
      @month   = Time.new _year, _month
      @price   = BigDecimal.new((opts.fetch(:price) { ENV['EMBED_PRICE_PER_MONTH'] }).to_i) / Time.days_in_month(@month.month)
    end

    def save_to_monthly_billings!
      return if usage_per_days.count == 0

      @mb = MonthlyBilling.new\
        organization_id: @org_id,
        period_beginning: @month.beginning_of_month,
        period_end: @month.end_of_month,
        total: 0

      @mb.save!

      total = BigDecimal.new(0)

      usage_per_days.each do |key, dates|
        brand_id, embed_id = key
        last_rec           = find_record(brand_id, embed_id).last
        description        = "Hub '#{last_rec.embed_name}' from organization '#{last_rec.organization_name}'"

        total += dates.count * @price
        total = (total >= 50) ? total : BigDecimal.new(50)
        @mb.monthly_billing_records << MonthlyBillingRecord.new(description: description, amount: dates.count, price: @price.round(2).to_i)
      end

      @mb.total = total.round(2).to_i
      @mb.save!
      @mb
    end

    def usage_per_days
      @usage_per_days ||= @ee_logs.reduce(Hash.new(Set.new([]))) do |acc, rec|
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

    def find_record(brand_id, embed_id)
      @ee_logs.select {|r| r.brand_id == brand_id && r.embed_id == embed_id}
    end

    private

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
