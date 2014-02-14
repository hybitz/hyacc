# coding: UTF-8
#
# $Id: tax_controller.rb 3145 2013-10-24 13:46:20Z ichy $
# Product: hyacc
# Copyright 2009-2013 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class TaxController < Base::HyaccController
  include JournalUtil

  available_for :type => :tax_management_type, :only => TAX_MANAGEMENT_TYPE_EXCLUSIVE
  view_attribute :finder, :class => TaxFinder, :only => :index
  view_attribute :ym_list, :only => :index
  view_attribute :branches, :only => :index

  def index
    @closing_status = current_user.company.get_fiscal_year( finder.fiscal_year ).closing_status
    @journal_headers = finder.list
  end
  
  def update_checked
    jh = JournalHeader.find(params[:id])
    if jh.nil?
      @message = '伝票が存在しません。id=' + params[:id]
      return
    elsif get_closing_status( jh ) == CLOSING_STATUS_CLOSED
    # 本締めの場合は更新不可
      render :text=>ERR_CLOSING_STATUS_CLOSED
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
