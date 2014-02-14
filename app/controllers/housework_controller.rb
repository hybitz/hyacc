# coding: UTF-8
#
# $Id: housework_controller.rb 3358 2014-02-07 05:27:26Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class HouseworkController < Base::HyaccController
  include JournalUtil
  
  available_for :type=>:company_type, :only=>COMPANY_TYPE_PERSONAL
  view_attribute :title => '家事按分'
  view_attribute :finder, :class=>HouseworkFinder, :only=>:index
  view_attribute :ym_list, :only=>:index
  view_attribute :accounts, :except=>:index,
    :conditions=>['account_type=? and journalizable=?', ACCOUNT_TYPE_EXPENSE, true]
  view_attribute :sub_accounts, :except=>:index
  
  def index
    @hw = finder.list
  end
  
  def new
    @hwd = HouseworkDetail.new
    @hwd.housework = Housework.find_by_fiscal_year(finder.fiscal_year) 
  end

  def create
    begin
      @hwd = HouseworkDetail.new(params[:hwd])
      @hwd.transaction do
        @hwd.save!
      end

      flash[:notice] = '家事按分を登録しました。'
      render 'common/reload'
    rescue Exception => e
      handle(e)
      render :new
    end
  end

  def edit
    @hwd = HouseworkDetail.find(params[:id])
  end
  
  def update
    @hwd = HouseworkDetail.find(params[:id])

    begin
      @hwd.transaction do
        @hwd.update_attributes!(params[:hwd])
      end
      
      flash[:notice] = '家事按分を更新しました。'
      render 'common/reload'
    rescue Exception => e
      handle(e)
      render :edit
    end
  end
  
  def destroy
    @hwd = HouseworkDetail.find(params[:id])

    begin
      @hwd.transaction do
        unless @hwd.destroy
          raise HyaccException.new
        end
        
        @hwd.housework.journal_headers.each do |jh|
          jh.save!
        end
      end
      
      flash[:notice] = '家事按分を削除しました。'
    rescue Exception => e
      handle(e)
    end
    
    redirect_to :action=>:index
  end
  
  def create_journal
    hw = Housework.find(params[:id])
    
    begin
      hw.transaction do
        param = Auto::Journal::HouseworkParam.new( hw, current_user )
        factory = Auto::AutoJournalFactory.get_instance( param )
        hw.journal_headers = factory.make_journals()
        hw.journal_headers.each do |jh|
          validate_journal(jh)
        end
        hw.save!
      end
    
      flash[:notice] = '家事按分仕訳を作成しました。'
    rescue Exception=>e
      handle(e)
    end
      
    redirect_to :action=>:index
  end
end
