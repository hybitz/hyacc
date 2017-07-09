require 'test_helper'

class TaskMailerTest < ActionMailer::TestCase
  def test_create
    toAddress = 'admin@hybitz.co.jp'
    subject = 'メールタイトル'
    attachments_path = __FILE__
    email = TaskMailer.create(toAddress, subject, attachments_path).deliver_now
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [toAddress], email.to
    assert_equal subject, email.subject
    assert_match /週次バックアップ/, email.encoded
  end
end