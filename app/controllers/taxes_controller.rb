class TaxesController < Base::HyaccController
  view_attribute :title => '消費税管理'
  view_attribute :finder, :class => TaxFinder, :only => :index
  view_attribute :ym_list, :only => :index
  view_attribute :branches, :only => :index

  def index
    @journal_headers = finder.list if finder.commit
  end

  def update
    j = Journal.find(params[:id])

    if j.fiscal_year.closed?
      # 本締めの場合は更新不可
      @message = ERR_CLOSING_STATUS_CLOSED
    else
      tai = j.tax_admin_info
      tai.checked = true
      unless tai.save
        @message = '伝票の更新に失敗しました。id=' + params[:id]
      end
    end
  end
end
