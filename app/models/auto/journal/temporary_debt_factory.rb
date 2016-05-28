module Auto::Journal

  # 仮負債仕訳ファクトリ
  class TemporaryDebtFactory < Auto::AutoJournalFactory
    
    def initialize( auto_journal_param )
      super( auto_journal_param )
      @params = auto_journal_param.params
      @user = auto_journal_param.user
    end
    
    def make_journals
      jh = @params[:jh].transfer_journals.build
      jh.company_id = @user.company.id
      jh.ym = @params[:ym]
      jh.day = @params[:day]
      jh.slip_type = SLIP_TYPE_TEMPORARY_DEBT
      jh.remarks = @params[:jh].remarks + '【仮負債精算】'
      jh.create_user_id = @user.id
      jh.update_user_id = @user.id

      ## 仮負債明細
      jd = jh.journal_details.build
      jd.detail_no = jh.journal_details.size
      jd.dc_type = DC_TYPE_DEBIT
      jd.account_id = @params[:jd].account_id
      jd.sub_account_id = @params[:jd].sub_account_id
      jd.branch_id = @params[:branch_id]
      jd.tax_type = TAX_TYPE_NONTAXABLE
      jd.amount = @params[:jd].amount
      
      ## 仮負債貸方（資産）明細
      jd = jh.journal_details.build
      jd.detail_no = jh.journal_details.size
      jd.dc_type = DC_TYPE_CREDIT
      jd.account_id = @params[:account_id]
      jd.sub_account_id = @params[:sub_account_id] unless @params[:sub_account_id].nil?
      jd.branch_id = @params[:branch_id]
      jd.amount = @params[:jd].amount
      jd.tax_type = TAX_TYPE_NONTAXABLE
      
      ## 資産明細
      branch_code = SubAccount.find(@params[:jd].sub_account_id).code
      assets_branch_id = Branch.find_by_code(branch_code).id
      jd = jh.journal_details.build
      jd.detail_no = jh.journal_details.size
      jd.dc_type = DC_TYPE_DEBIT
      jd.account_id = @params[:account_id]
      jd.sub_account_id = @params[:sub_account_id] unless @params[:sub_account_id].nil?
      jd.branch_id = assets_branch_id
      jd.amount = @params[:jd].amount
      jd.tax_type = TAX_TYPE_NONTAXABLE
      
      ## 仮資産明細
      assets = Account.get_by_code(ACCOUNT_CODE_TEMPORARY_ASSETS)
      jd = jh.journal_details.build
      jd.detail_no = jh.journal_details.size
      jd.dc_type = DC_TYPE_CREDIT
      jd.account_id = assets.id
      jd.branch_id = assets_branch_id
      jd.amount = @params[:jd].amount
      jd.tax_type = TAX_TYPE_NONTAXABLE
    end
  end
end
