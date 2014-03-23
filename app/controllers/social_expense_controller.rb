class SocialExpenseController < Base::HyaccController
  include JournalUtil
  
  available_for :type => :company_type, :except => COMPANY_TYPE_PERSONAL
  view_attribute :finder, :class => SocialExpenseFinder, :except => :update
  view_attribute :ym_list, :except=>:update
  view_attribute :branches, :except=>:update

  def index
    @closing_status = current_user.company.get_fiscal_year( finder.fiscal_year ).closing_status
    @journal_headers = finder.list
  end
  
  def report
    if finder.commit
      @sem = create_social_expense_model
    end
  end
  
  def update
    detail = JournalDetail.find(params[:id])
    if detail.nil?
      render :text=>'データが存在しません。' and return
    end
    
    # 本締めの場合は更新不可
    if get_closing_status( detail.journal_header ) == CLOSING_STATUS_CLOSED
      render :text=>ERR_CLOSING_STATUS_CLOSED and return
    end
    
    detail.social_expense_number_of_people = params[:social_expense_number_of_people]
    if detail.save
      render :text=>'OK' # クライアント側のAjax更新処理は成功したかどうかを「OK」という文字列で判定する
    else
      text = detail.errors[:sub_account]
      text = detail.errors[:account] if text.nil?
      text = detail.errors[:social_expense_number_of_people] if text.nil?
      text = ERR_DB if text.nil?
      render :text=>text
    end
    
  end

  protected

  def create_social_expense_model
    ret = SocialExpense::SocialExpenseModel.new
    ret.fiscal_year = finder.fiscal_year
    ret.company = current_user.company
    ret.capital_stock = get_capital_stock( finder.fiscal_year )
    ret.add_detail( finder.get_social_expense_detail_model() )
    ret.extend_details_up_to( 11 )
    ret
  end
end
