namespace :hyacc do
  namespace :notification do

    desc "6月1日に算定基礎届提出期限のお知らせを生成"
    task generate: :environment do
      puts "お知らせ生成を開始"
    
      due_date = Date.new(Date.today.year, 7, 10)
      due_date += 1 while !HyaccDateUtil.weekday?(due_date)
      message = "#{TaxJp::Gengou.to_wareki(Date.new(due_date.year.to_i, 12, 31), only_date: false, format: '%y')}年の算定基礎届の提出期限は #{due_date.strftime("%-m月%d日")} です。"
      begin
        notification = Notification.create!(message: message)
        puts "お知らせ生成成功: message=#{message}"
      rescue => e
        puts "お知らせ生成失敗: error=#{e.message}"
        Rails.logger.error("お知らせ生成失敗: error=#{e.message}")
      end

      User.where(deleted: false).find_each do |user|
        begin
          user.user_notifications.create!(notification: notification)
          puts "お知らせの紐づけ成功: user_id=#{user.id}"
        rescue => e
          puts "お知らせの紐づけ失敗: user_id=#{user.id}, error=#{e.message}"
          Rails.logger.error("お知らせの紐づけ失敗: user_id=#{user.id}, error=#{e.message}")
        end
      end
    end

    desc "9月1日に算定基礎届提出期限のお知らせを削除"
    task cleanup: :environment do
      puts "お知らせ削除を開始"
      notification = Notification.last

      if notification
        begin
          notification.destroy!
          puts "お知らせ削除成功: notification_id=#{notification.id}"
        rescue => e
          puts "お知らせ削除失敗: error=#{e.message}"
          Rails.logger.error("お知らせ削除失敗: error=#{e.message}")
        end
      else
        puts "削除対象のお知らせは存在しません"
      end
    end
  end
end