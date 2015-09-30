class OrganizationMailer < ApplicationMailer

  def receipt_email(billing)
    @billing = billing
    mail(to: @billing.organization.accounts.pluck(:email), subject: @billing.description)
  end
end
