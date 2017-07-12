class TaskMailer < ApplicationMailer

  def create(to, subject, attachments_path, options = {})
    @now = options.fetch(:now, Time.now)

    attachments[File.basename(attachments_path)] = {
      :content => File.read(attachments_path, :mode => 'rb'),
      :transfer_encoding => :binary
    }

    mail(:to => to, :subject => subject)
  end

end
