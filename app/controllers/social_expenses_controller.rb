class SocialExpensesController < Base::HyaccController
  include JournalUtil
  
  available_for :type => :company_type, :except => COMPANY_TYPE_PERSONAL
  view_attribute :title => '交際費管理'
  view_attribute :finder, :class => SocialExpenseFinder, :except => :update
  view_attribute :ym_list, :except=>:update
  view_attribute :branches, :except=>:update

  def index
    @journal_headers = finder.list
  end
  
  def update
    detail = JournalDetail.find(params[:id])
    if detail.nil?
      render :text=>'データが存在しません。' and return
    end
    
    # 本締めの場合は更新不可
    if get_closing_status( detail.journal_header ) == CLOSING_STATUS_CLOSED
      render :text => ERR_CLOSING_STATUS_CLOSED and return
    end
    
    detail.social_expense_number_of_people = params[:social_expense_number_of_people]
    if detail.save
      render :text=>'OK' # クライアント側のAjax更新処理は成功したかどうかを「OK」という文字列で判定する
    else
      text = detail.errors[:sub_account]
      text ||= detail.errors[:account]
      text ||= detail.errors[:social_expense_number_of_people]
      text ||= ERR_DB
      render :text => text
    end
    
  end

end
