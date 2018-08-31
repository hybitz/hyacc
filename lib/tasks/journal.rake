require 'rake'

namespace :hyacc do
  namespace :journal do

    desc '明細のない伝票を検索します'
    task :without_details => :environment do
      sql = SqlBuilder.new
      sql.append('not exists (')
      sql.append('  select 1 from journal_details jd where jd.journal_id = journals.id')
      sql.append(')')
      puts Journal.where(sql.to_a).to_yaml
    end
  end
end