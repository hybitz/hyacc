require 'rake'

namespace :hyacc do
  namespace :charset do
    desc '既存テーブル/カラムをutf8mb4へ変換します'
    task :convert_to_utf8mb4 => :environment do
      connection = ActiveRecord::Base.connection
      charset = 'utf8mb4'
      collation = 'utf8mb4_general_ci'

      connection.tables.each do |table|
        sql = "ALTER TABLE #{connection.quote_table_name(table)} " \
              "CONVERT TO CHARACTER SET #{charset} " \
              "COLLATE #{collation}"
        puts sql
        connection.execute(sql)
      end
    end
  end
end
