# coding: UTF-8
#
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AssetController < Base::HyaccController
  include Depreciation::DepreciationUtil

  view_attribute :title => '資産管理'
  view_attribute :finder, :class => AssetFinder, :only=>:index
  view_attribute :ym_list, :only => :index
  view_attribute :branches, :only => :index
  view_attribute :accounts, :only => :index,
    :conditions=>['account_type=? and trade_type=? and deleted=? and depreciable=?',
      ACCOUNT_TYPE_ASSET, TRADE_TYPE_EXTERNAL, false, true]

  def index
    render :no_account and return unless @accounts.present?

    @assets = finder.list
  end

  def show
    @asset = Asset.find(params[:id])
  end
  
  def edit
    @asset = Asset.find(params[:id])
  end
  
  def update
    @asset = Asset.find(params[:id])
    @asset.attributes = params[:asset]
    
    if params[:commit] == '償却待に設定'
      raise HyaccException.new(ERR_INVALID_ACTION) unless @asset.status_created?
      @asset.status = ASSET_STATUS_WAITING
    elsif params[:commit] == '償却待を解除'
      raise HyaccException.new(ERR_INVALID_ACTION) unless @asset.status_waiting?
      @asset.status = ASSET_STATUS_CREATED
    elsif params[:commit] == '償却実行'
      raise HyaccException.new(ERR_INVALID_ACTION) unless @asset.status_waiting? or @asset.status_depreciating?
      @asset.status = ASSET_STATUS_DEPRECIATING
    end

    begin
      @asset.transaction do
        if @asset.status_created?
          @asset.depreciations.clear
        elsif @asset.status_waiting?
          @asset.depreciations = create_depreciations(@asset)
        elsif @asset.status_depreciating?
          d = @asset.depreciations.find_by_fiscal_year(current_user.company.current_fiscal_year_int)
          d.journal_headers = create_journals(d, current_user)
          d.depreciated = true
          d.save!
          if @asset.depreciations.count(:all, :conditions=>['depreciated=?', false]) == 0
            @asset.status = ASSET_STATUS_DEPRECIATED
          end
        end
        
        @asset.save!
      end

      flash[:notice] = '資産を更新しました。'
      render 'common/reload'

    rescue Exception => e
      handle(e)
      @asset.status = @asset.status_was
      render 'edit'
    end
  end  
end
