# Run `rake stripe:prepare` to update coupons on stripe.com

# Stripe.coupon :gold25 do |coupon|
#   coupon.duration = 'repeating' # 'once', 'forevere', 'repeating'
#   coupon.amount_off = 199 # cents
#   coupon.currency = 'usd'
#   coupon.duration_in_months = 6 # only valid for duration of 'repeating'
#   coupon.percent_off = 25
#   coupon.reedem_by = (Time.now + 15.days).utc
#   coupon.max_redemptions = 10
# end
