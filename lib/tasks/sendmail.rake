require 'rake'

namespace :hyacc do
  namespace :sendmail do

    desc "データベースのバックアップファイルをメールで送信する。"
    task :dbdata => :environment do
      # 今日の日付を取得
      now = Time.now
      ym = now.strftime("%Y%m")

      # 最新のDBデータファイルパスを取得
      dbdata_path = Dir.glob(File.join('/data/hyacc', Rails.env, 'backup', ym, '*_pro_*.sql.zip')).last

      # companiesテーブルから管理者メールを取得
      c = Company.first
      to = c.admin_email

      if File.exist?(dbdata_path) && to.present?
        mail_title = "【Hyacc】週次バックアップ(#{now.to_s(:ymd)})"

        #メールの送信
        TaskMailer.create(to, mail_title, dbdata_path, :now => now).deliver_now 
      end
    end

  end
end





