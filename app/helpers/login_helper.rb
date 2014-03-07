# coding: UTF-8

module LoginHelper

  # アラートメールの送信先を取得します。
  def get_alert_mail_to(user)
    to = user.email if user
    to = Company.find(:first).admin_email unless to.present?
    to
  end

end
