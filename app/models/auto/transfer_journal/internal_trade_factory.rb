module Auto::TransferJournal
  
  # 内部取引を本店集中会計制度に従って処理する自動振替ファクトリ
  class InternalTradeFactory < Auto::AutoJournalFactory
    include JournalUtil
    
    def initialize( auto_journal_param )
      super( auto_journal_param )
      @src_jh = auto_journal_param.journal_header
    end
    
    def make_journals()
      # 伝票と伝票に紐付いているすべての自動振替伝票をリストアップ
      related_journals = get_all_related_journals(@src_jh)
      
      # 各伝票ごとに支店間または本支店間取引があるか確認し、あれば内部取引仕訳を作成する
      related_journals.each do |rj|
        # 部門別に金額を集計
        balance_by_branch_map = make_balance_by_branch_map( [rj] )

        balance_by_branch_map.each_value{|value|
          # 貸借の金額が異なれば仕訳を作成
          diff = value.amount_debit - value.amount_credit
          if diff != 0
            transfer_journal = make_transfer_journal( rj.ym, rj.day, value.branch_id, diff )
            rj.transfer_journals << transfer_journal if transfer_journal
          end
        }
      end
    end
    
  private
    def make_transfer_journal( ym, day, branch_id, amount )
      branch = Branch.get( branch_id )
      
      # 部門が本店の場合は振替不要
      return nil if branch.is_head_office
      
      # 支店の場合は本店との振替仕訳を作成する
      jh = JournalHeader.new
      jh.company_id = @src_jh.company_id
      jh.ym = ym
      jh.day = day
      jh.slip_type = SLIP_TYPE_AUTO_TRANSFER_INTERNAL_TRADE
      jh.remarks = @src_jh.remarks + '【内部取引】'
      jh.create_user_id = @src_jh.create_user_id
      jh.created_at = @src_jh.created_at
      jh.update_user_id = @src_jh.update_user_id
      jh.updated_at = @src_jh.updated_at
      
      # 明細作成準備
      detail_no = 0
      head_office = branch.company.get_head_office
      account_head_office = Account.get_by_code(ACCOUNT_CODE_HEAD_OFFICE)
      account_branch_office = Account.get_by_code(ACCOUNT_CODE_BRANCH_OFFICE)
      dc_type = amount < 0 ? DC_TYPE_DEBIT : DC_TYPE_CREDIT
      amount = amount.abs
      
      # 明細作成
      # 支店分の明細を作成
      detail_no += 1
      jd = JournalDetail.new
      jd.detail_no = detail_no
      jd.dc_type = dc_type
      jd.account_id = account_head_office.id
      jd.branch_id = branch_id
      jd.amount = amount
      jd.created_at = @src_jh.created_at
      jd.updated_at = @src_jh.updated_at
      jh.journal_details << jd
      
      # 本店分の明細を作成
      detail_no += 1
      jd2 = JournalDetail.new
      jd2.detail_no = detail_no
      jd2.dc_type = opposite_dc_type( dc_type )
      jd2.account_id = account_branch_office.id
      jd2.sub_account_id = account_branch_office.get_sub_account_by_code(branch.code).id 
      jd2.branch_id = head_office.id
      jd2.amount = amount
      jd2.created_at = @src_jh.created_at
      jd2.updated_at = @src_jh.updated_at
      jh.journal_details << jd2
      
      jh
    end
  end
end
