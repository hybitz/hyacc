class TaxController < Base::HyaccController
  include JournalUtil

  available_for :type => :tax_management_type, :only => TAX_MANAGEMENT_TYPE_EXCLUSIVE
  view_attribute :finder, :class => TaxFinder, :only => :index
  view_attribute :ym_list, :only => :index
  view_attribute :branches, :only => :index

  def index
    @journal_headers = finder.list if finder.commit
  end
  
  def update_checked
    jh = JournalHeader.find(params[:id])

    if get_closing_status( jh ) == CLOSING_STATUS_CLOSED
      # 本締めの場合は更新不可
      @message = ERR_CLOSING_STATUS_CLOSED
    else
      tai = jh.tax_admin_info
      tai.checked = true
      unless tai.save
        @message = '伝票の更新に失敗しました。id=' + params[:id]
      end
    end
  end
end
