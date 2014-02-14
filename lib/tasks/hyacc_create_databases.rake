# coding: UTF-8

require 'rake'
require 'yaml'

namespace :hyacc do
  desc "Hyaccのデータベースと接続ユーザを作成します。"
  task :create_databases do
    system("mkdir -p tmp")
    system("echo '# 以下のSQLを実行します。' > tmp/create_databases.sql")
    system("echo >> tmp/create_databases.sql")
  
    config = YAML.load_file("#{Rails.root}/config/database.yml")
    config.each do |env, values|
      system("echo '# #{env}' >> tmp/create_databases.sql")
      system("echo 'drop database if exists #{values['database']};' >> tmp/create_databases.sql")
      system("echo 'create database #{values['database']};' >> tmp/create_databases.sql")
      system("echo 'grant all on #{values['database']}.* to #{values['username']} identified by \"#{values['password']}\";' >> tmp/create_databases.sql")
      system("echo >> tmp/create_databases.sql")
    end
    
    system("cat tmp/create_databases.sql")
    system("mysql -u root -p < tmp/create_databases.sql")
  end
end
