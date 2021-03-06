module Auto::TransferJournal

  # 未払費用の自動振替
  class AccruedExpenseFactory < Auto::AutoJournalFactory

    def initialize( auto_journal_param )
      super( auto_journal_param )
      @src_jd = auto_journal_param.journal_detail
    end

    def make_journals
      auto = @src_jd.transfer_journals.build(auto: true)
      auto.company_id = @src_jd.journal.company_id
      auto.ym = HyaccDateUtil.last_month(@src_jd.journal.ym)
      auto.day = HyaccDateUtil.last_day_of_month( auto.ym )
      auto.remarks = @src_jd.journal.remarks + '【自動】'
      auto.slip_type = SLIP_TYPE_AUTO_TRANSFER_ACCRUED_EXPENSE
      auto.create_user_id = @src_jd.journal.create_user_id
      auto.update_user_id = @src_jd.journal.update_user_id

      auto_jd = auto.journal_details.build
      auto_jd.detail_no = auto.journal_details.size
      auto_jd.dc_type = @src_jd.dc_type
      auto_jd.account_id = @src_jd.account_id
      auto_jd.sub_account_id = @src_jd.sub_account_id
      auto_jd.branch_id = @src_jd.branch_id
      auto_jd.amount = @src_jd.amount
      auto_jd.social_expense_number_of_people = @src_jd.social_expense_number_of_people

      # 繰越明細を作成
      auto_jd = auto.journal_details.build
      auto_jd.detail_no = auto.journal_details.size
      auto_jd.dc_type = HyaccUtil.opposite_dc_type(@src_jd.dc_type)
      auto_jd.account_id = Account.find_by_code( ACCOUNT_CODE_ACCRUED_EXPENSE ).id
      auto_jd.sub_account_id = nil
      auto_jd.branch_id = @src_jd.branch_id
      auto_jd.amount = @src_jd.amount

      # 逆仕訳の作成
      next_day = Date.new(auto.ym/100, auto.ym%100, auto.day ).next
      reverse = auto.transfer_journals.build(auto: true)
      reverse.company_id = auto.company_id
      reverse.ym = @src_jd.journal.ym
      reverse.day = @src_jd.journal.day
      reverse.remarks = auto.remarks + '【逆】'
      reverse.slip_type = auto.slip_type
      reverse.create_user_id = auto.create_user_id
      reverse.update_user_id = auto.update_user_id
      auto.journal_details.each do |jd|
        reverse_jd = reverse.journal_details.build
        reverse_detail(jd, reverse_jd)
      end
    end
  end
end
