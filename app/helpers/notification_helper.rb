module NotificationHelper
  def formatted_message(notification)
    message = notification.message
    message.gsub(/(\d{1,2}月\d{1,2}日)/) do |match| 
      content_tag(:span, match, style: 'color: red;')
    end.html_safe
  end
end