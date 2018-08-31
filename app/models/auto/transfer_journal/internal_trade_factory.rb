module Auto::TransferJournal

  # 内部取引を本店集中会計制度に従って処理する自動振替ファクトリ
  class InternalTradeFactory < Auto::AutoJournalFactory

    def initialize( auto_journal_param )
      super(auto_journal_param)
      @src_jh = auto_journal_param.journal
    end

    def make_journals
      # 伝票と伝票に紐付いているすべての自動振替伝票をリストアップ
      related_journals = @src_jh.get_all_related_journals

      # 各伝票ごとに支店間または本支店間取引があるか確認し、あれば内部取引仕訳を作成する
      related_journals.each do |rj|
        # 部門別に金額を集計
        balance_by_branch_map = JournalUtil.make_balance_by_branch_map( [rj] )

        balance_by_branch_map.each_value do |value|
          # 貸借の金額が異なれば仕訳を作成
          diff = value.amount_debit - value.amount_credit
          if diff != 0
            make_transfer_journal(rj, value.branch_id, diff)
          end
        end
      end
    end

    private

    def make_transfer_journal(parent_jh, branch_id, amount)
      # 部門が本店の場合は振替不要
      branch = Branch.find(branch_id)
      return if branch.head_office?

      # 支店の場合は本店との振替仕訳を作成する
      jh = parent_jh.transfer_journals.build(auto: true)
      jh.company_id = @src_jh.company_id
      jh.ym = parent_jh.ym
      jh.day = parent_jh.day
      jh.slip_type = SLIP_TYPE_AUTO_TRANSFER_INTERNAL_TRADE
      jh.remarks = @src_jh.remarks + '【内部取引】'
      jh.create_user_id = @src_jh.create_user_id
      jh.update_user_id = @src_jh.update_user_id

      # 明細作成準備
      head_office = branch.company.head_branch
      account_head_office = Account.find_by_code(ACCOUNT_CODE_HEAD_OFFICE)
      account_branch_office = Account.find_by_code(ACCOUNT_CODE_BRANCH_OFFICE)
      dc_type = amount < 0 ? DC_TYPE_DEBIT : DC_TYPE_CREDIT
      amount = amount.abs

      # 明細作成
      # 支店分の明細を作成
      jd = jh.journal_details.build
      jd.detail_no = jh.journal_details.size
      jd.dc_type = dc_type
      jd.account_id = account_head_office.id
      jd.branch_id = branch_id
      jd.amount = amount

      # 本店分の明細を作成
      jd2 = jh.journal_details.build
      jd2.detail_no = jh.journal_details.size
      jd2.dc_type =  HyaccUtil.opposite_dc_type(dc_type)
      jd2.account_id = account_branch_office.id
      jd2.sub_account_id = account_branch_office.get_sub_account_by_code(branch.code).id
      jd2.branch_id = head_office.id
      jd2.amount = amount
    end
  end
end
