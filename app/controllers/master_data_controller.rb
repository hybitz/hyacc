# coding: UTF-8
#
# $Id: master_data_controller.rb 2976 2012-12-21 08:28:10Z ichy $
# Product: hyacc
# Copyright 2009-2012 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class MasterDataController < Base::HyaccController
  require 'net/http'

  # 指定された勘定科目の補助科目リストを取得する
  def get_sub_accounts
    @sub_accounts = load_sub_accounts(params[:account_id], params)
    
    respond_to do |format|
      format.html { render :partial => 'common/get_sub_accounts' }
      format.xml  { render :xml => @sub_accounts }
      format.json { render :json => @sub_accounts.collect{|sa| {:id=>sa.id, :name=>sa.name}}}
    end
  end

  # 指定された金融機関の支店を取得する
  def get_bank_offices
    bank_offices = load_bank_offices(params[:bank_id], params)
    
    respond_to do |format|
      format.json  { render :json => bank_offices.collect{|bo| bo = {:id=>bo.id, :name=>bo.name}}}
    end
  end
  
  # 都道府県一覧を取得する
  def get_prefectures
    @prefectures = super
    render :text=>@prefectures.to_json
  end
end
