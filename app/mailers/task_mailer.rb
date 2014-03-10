# -*- encoding : utf-8 -*-
class TaskMailer < ActionMailer::Base
  default from: "info@hybitz.co.jp"
   def create(toAddress, subject, message, attachments_path)
     attachments[File.basename(attachments_path)] = {
       :content => File.read(attachments_path, :mode => 'rb'),
       :transfer_encoding => :binary
      }
      mail(:to => toAddress,
           :subject => subject,
           :body => message
           )
   end
end