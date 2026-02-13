class MigrateInvestmentJournalDetailToJournal < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL.squish
      UPDATE journals j
      INNER JOIN journal_details jd ON jd.journal_id = j.id
      INNER JOIN investments i ON i.journal_detail_id = jd.id
      SET j.investment_id = i.id
    SQL
  end

  def down
    execute <<-SQL.squish
      UPDATE journals SET investment_id = NULL WHERE investment_id IS NOT NULL
    SQL
  end
end
