class DeleteJournalHeadersWithoutDetails < ActiveRecord::Migration
  def change
    sql = SqlBuilder.new
    sql.append('not exists (')
    sql.append('  select 1 from journal_details jd where jd.journal_header_id = journal_headers.id')
    sql.append(')')
    Journal.where(sql.to_a).each do |jh|
      puts jh.to_yaml
      jh.destroy
    end
  end
end
