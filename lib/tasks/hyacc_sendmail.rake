# coding: UTF-8
namespace :hyacc do
  namespace :sendmail do
    desc "データベースのバックアップファイルをメールで送信する。"
    task :dbdata => :environment do
      # 会社名の定義→DBへ
      company_name = "hybitz"
      # 今日の日付を取得
      ym = Time.now.strftime("%Y%m")
      ymd = Time.now.strftime("%Y%m%d")
      yyyymmdd = Time.now.strftime("%Y/%m/%d")
      
      # 最新のDBデータファイルパスを取得
      dbdata_path = "/home/hyacc/backup/" + company_name + "/" + ym + "/" + company_name + "_pro_" + ymd + ".sql.zip"
      dbdata_path = __FILE__ if Rails.env != "production"
      
      # companiesテーブルから管理者メールを取得
      to = Company.first.admin_email
      
      # メールを送信
      mail_title = "【Hyacc】週次バックアップ(" + yyyymmdd + ")"
      mail_body = "週次バックアップ(" + yyyymmdd + ")"
      
      #メールの送信
      TaskMailer.create(to, mail_title, mail_body,dbdata_path).deliver if File.exist?(dbdata_path) && to.present?
    end
  end
end





