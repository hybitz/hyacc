# coding: UTF-8
#
# $Id: debt_controller.rb 3340 2014-02-01 02:50:49Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class DebtController < Base::HyaccController
  include JournalUtil
  
  available_for :type => :branch_mode, :only => true
  view_attribute :title => '仮負債精算'
  view_attribute :finder, :class => DebtFinder, :only => :index
  view_attribute :ym_list, :only => :index
  view_attribute :branches, :only => :index
  # 流動資産のみ対象
  view_attribute :accounts, :only => :index, :conditions => "path like '%" + ACCOUNT_CODE_CURRENT_ASSETS + "%'"
  view_attribute :sub_accounts, :include => :deleted, :only => :index

  def index
    @ymd = params[:ymd] || Date.today.end_of_month
    @debts, @sum = finder.list if finder.commit
  end
  
  # 仮負債を精算する
  def update
    begin
      closed_id = do_close(params, current_user)
      render :partial => 'closed_link', :locals => {:closed_id => closed_id}
    rescue Exception => e
      handle(e)
      render :nothing => true, :status => :internal_server_error
    end
  end
  
  private
  
  # 仮負債を精算する
  def do_close(params, user)
    split = params[:ymd].split('-')
    params[:ym] = split[0..1].join
    params[:day] = split[2]

    jh = JournalHeader.find(params[:id])
    # 締め状態のチェック用
    old = JournalHeader.find(params[:id])
    
    params[:jh] = jh
    a = Account.get_by_code(ACCOUNT_CODE_TEMPORARY_DEBT)
    jh.journal_details.where(:account_id => a.id, :branch_id => params[:branch_id]).each do |jd|
      params[:jd] = jd
    end

    # 仮負債仕訳
    param = Auto::Journal::TemporaryDebtParam.new( params, user )
    factory = Auto::AutoJournalFactory.get_instance( param )
    jh.transaction do
      jh.transfer_journals << factory.make_journals()
      validate_closing_status_on_update( jh, old )
      jh.save!
    end
    jh.transfer_journals.last.id
  end
end
