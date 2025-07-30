namespace :hyacc do
  namespace :notification do

    desc "6月1日に算定基礎届提出期限のお知らせを生成"
    task generate: :environment do
      puts "お知らせ生成を開始" unless Rails.env.test?
    
      due_date = Date.new(Date.today.year, 7, 10)
      due_date += 1 while !HyaccDateUtil.weekday?(due_date)
      message = "#{TaxJp::Gengou.to_wareki(Date.new(due_date.year.to_i, 12, 31), only_date: false, format: '%y')}年の算定基礎届の提出期限は #{due_date.strftime("%-m月%d日")} です。"
      notification = Notification.find_by(message: message)
      begin
        if notification&.deleted
          notification.update!(deleted: false)
          puts "論理削除を解除: notification_id=#{notification.id} message=#{message}" unless Rails.env.test?
        elsif notification.nil?
          notification = Notification.create!(category: :report_submission, message: message)
          puts "お知らせ生成成功: message=#{message}" unless Rails.env.test?
        else
          puts "既に有効なお知らせが存在: notification_id=#{notification.id} message=#{message}" unless Rails.env.test?
        end
      rescue => e
        puts "お知らせ生成失敗: error=#{e.message}" unless Rails.env.test?
        Rails.logger.error("お知らせ生成失敗: error=#{e.message}")
        return
      end

      return if notification.deleted?
      User.where(deleted: false).find_each do |user|
        relation = user.user_notifications.find_by(notification_id: notification.id)
        begin
          if relation.nil?
            user.user_notifications.create!(notification: notification)
            puts "お知らせの紐づけ成功: user_id=#{user.id}" unless Rails.env.test?
          else
            puts "既に有効な紐づけ済み: user_id=#{user.id}" unless Rails.env.test?
          end
        rescue => e
          puts "お知らせの紐づけ失敗: user_id=#{user.id}, error=#{e.message}" unless Rails.env.test?
          Rails.logger.error("お知らせの紐づけ失敗: user_id=#{user.id}, error=#{e.message}")
        end
      end
    end

    desc "9月1日に算定基礎届提出期限のお知らせを削除"
    task cleanup: :environment do
      puts "お知らせ削除を開始" unless Rails.env.test?
      due_date = Date.new(Date.today.year, 7, 10)
      due_date += 1 while !HyaccDateUtil.weekday?(due_date)
      message = "#{TaxJp::Gengou.to_wareki(Date.new(due_date.year.to_i, 12, 31), only_date: false, format: '%y')}年の算定基礎届の提出期限は #{due_date.strftime("%-m月%d日")} です。"
      notification = Notification.find_by(message: message)

      if notification.nil?
        puts "削除対象のお知らせは存在しません" unless Rails.env.test?
      elsif notification.deleted
        puts "既に削除済み: notification_id=#{notification.id}" unless Rails.env.test?
      else
        begin
          notification.update!(deleted: true)
          puts "お知らせ削除成功: notification_id=#{notification.id}" unless Rails.env.test?
        rescue => e
          puts "お知らせ削除失敗: error=#{e.message}"
          Rails.logger.error("お知らせ削除失敗: error=#{e.message}") unless Rails.env.test?
        end
      end
    end
  end
end