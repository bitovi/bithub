class OrganizationMailer < ApplicationMailer
  default from: '"BitHub" <no-reply@bithub.com>'

  def receipt_email(billing)
    @billing = billing
    mail(to: @billing.organization.accounts.pluck(:email), subject: "Your BitHub receipt")
  end
end
