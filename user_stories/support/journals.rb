module Journals
  
  def create_journal(journal)
    visit_journals
    click_on '追加'

    within_dialog('振替伝票　追加') do
      with_capture do
        fill_in 'journal[ym]', with: journal.ym
        fill_in 'journal[day]', with: journal.day
        fill_in 'journal[remarks]', with: journal.remarks
        
        journal.journal_details.each_with_index do |jd, i|
          within find('.journal_details tbody').all('tr')[i*4] do
            select jd.dc_type_name, :from => find('[name*="\[dc_type\]"]')['id']
            find('[name*="\[account_id\]"]').first(:option, jd.account.code_and_name).select_option
          end
          assert has_selector?("[data-index=\"#{i}\"].sub_account_ready")
          within find('.journal_details tbody').all('tr')[i*4] do
            select jd.sub_account.name, :from => find('[name*="\[sub_account_id\]"]')['id'] if jd.sub_account.present?
            select jd.branch.name, :from => find('[name*="\[branch_id\]"]')['id']
            fill_in find('[name*="\[input_amount\]"]')['id'], with: jd.input_amount
          end

          if jd.allocation_type
            within find('.journal_details tbody').all('tr')[i*4+1] do
              selector = '[name*="\[allocation_type\]"][value="' + jd.allocation_type.to_s + '"]'
              check ALLOCATION_TYPES[jd.allocation_type]
            end
          end
        end
      end
      click_on '登録'
    end
  
    with_capture do
      assert has_selector?('.notice')
    end
  end
end

World(Journals)