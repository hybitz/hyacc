namespace :hyacc do
  namespace :payroll_notification do

    desc "Payrollからお知らせを登録・削除"
    task handle_and_cleanup_based_on_payroll: :environment do
      puts "Payrollからお知らせの登録・削除を開始する" unless Rails.env.test?
      PayrollNotification::PayrollNotificationProcessor.call
    end

  end
end