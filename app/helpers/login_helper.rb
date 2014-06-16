module LoginHelper

  # アラートメールの送信先を取得します。
  def get_alert_mail_to(user)
    to = user.email if user
    to ||= Company.first.admin_email
    to
  end

end
