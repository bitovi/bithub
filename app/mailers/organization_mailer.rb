class OrganizationMailer < ApplicationMailer
  default from: '"BitHub" <no-reply@bithub.com>'

  def receipt_email(billing)
    @billing = billing
    mail(to: @billing.organization.users.pluck(:email), subject: "Your BitHub receipt")
  end
end
