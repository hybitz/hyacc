class ApplicationMailer < ActionMailer::Base
  default from: 'info@hybitz.co.jp'
  layout 'mailer'

  def mail(headers = {})
    m = super
    m.transport_encoding = '8bit'
    m
  end

end
