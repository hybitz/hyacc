require 'rake'

namespace :hyacc do
  namespace :assets do

    desc '減価償却を未実施の資産を一覧します'
    task without_depreciation: :environment do
      sql = SqlBuilder.new
      sql.append('not exists (')
      sql.append('  select 1 from depreciations d')
      sql.append('  inner join journals j on (j.depreciation_id = d.id)')
      sql.append('  where d.asset_id = assets.id')
      sql.append(')')
      Asset.where(deleted: false).where(sql.to_a).order('ym, id').each do |a|
        attrs = {id: a.id, code: a.code, ym: a.ym, name: a.name, amount: a.amount, status: a.status_name}
        puts attrs
      end
    end

  end
end
