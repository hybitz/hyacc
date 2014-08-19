require 'test_helper'

class TaskMailerTest < ActionMailer::TestCase
  def test_create
    toAddress = 'admin@hybitz.co.jp'
    subject = 'メールタイトル'
    message = 'testmessage'
    attachments_path = __FILE__
    email = TaskMailer.create(toAddress, subject, message, attachments_path).deliver
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [toAddress], email.to
    assert_equal subject, email.subject
    assert_match /testmessage/, email.encoded
  end
end