もし /^本店から資金を異動$/ do |ast_table|
  to_journals(ast_table).each do |journal|
    create_journal(journal)
  end
end

もし /^タクシー代を精算$/ do |ast_table|
  to_journals(ast_table).each do |journal|
    journal.journal_details[0].allocation_type = ALLOCATION_TYPE_SHARE_BY_EMPLOYEE
    journal.journal_details[1].allocation_type = ALLOCATION_TYPE_SHARE_BY_EMPLOYEE
    create_journal(journal)
  end
end
