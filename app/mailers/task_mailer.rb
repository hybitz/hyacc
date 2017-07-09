class TaskMailer < ApplicationMailer

  def create(toAddress, subject, attachments_path, options = {})
    @now = options.fetch(:now, Time.now)

    attachments[File.basename(attachments_path)] = {
      :content => File.read(attachments_path, :mode => 'rb'),
      :transfer_encoding => :binary
    }
    mail(
      :to => toAddress,
      :subject => subject
    )
  end

end
