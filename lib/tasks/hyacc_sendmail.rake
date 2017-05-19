require 'rake'

namespace :hyacc do
  namespace :sendmail do

    desc "データベースのバックアップファイルをメールで送信する。"
    task :dbdata => :environment do
      c = Company.first

      # 今日の日付を取得
      now = Time.now
      ym = now.strftime("%Y%m")
      ymd = now.strftime("%Y%m%d")
      yyyymmdd = now.strftime("%Y/%m/%d")
        
      # 最新のDBデータファイルパスを取得
      dbdata_file = c.name + '_pro_' + ymd + '.sql.zip'
      dbdata_path = File.join('/home/hyacc/backup', c.name, ym, dbdata_file) 

      # companiesテーブルから管理者メールを取得
      to = c.admin_email

      if File.exist?(dbdata_path) && to.present?
        mail_title = "【Hyacc】週次バックアップ(" + yyyymmdd + ")"
        mail_body = "週次バックアップ(" + yyyymmdd + ")"
          
        #メールの送信
        TaskMailer.create(to, mail_title, mail_body, dbdata_path).deliver_now 
      end
    end

  end
end





