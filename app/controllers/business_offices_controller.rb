# coding: UTF-8
#
# $Id: company_controller.rb 2419 2011-01-14 03:26:53Z ichy $
# Product: hyacc
# Copyright 2009-2012 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class BusinessOfficesController < Base::HyaccController
  layout 'application'
  view_attribute :title=>'事業所'

  def new
    begin
      setup_view_attributes
      @bo = BusinessOffice.new(:company_id=>params[:company_id])
    rescue Exception => e
      handle(e)
    end
  end
  
  def create
    begin
      setup_view_attributes
      @bo = BusinessOffice.new(params[:business_office])
      @bo.prefecture_name = @prefectures.find{|p| p[1] == @bo.prefecture_id}[0]

      @bo.save!
      flash[:notice] = '事業所を登録しました。'
      render :partial=>'common/reload_dialog'
    rescue Exception => e
      handle(e)
      render :action => 'add'
    end
  end
  
  def edit
    begin
      setup_view_attributes
      @bo = BusinessOffice.find(params[:id])
    rescue Exception => e
      handle(e)
    end
  end
  
  def update
    begin
      setup_view_attributes
      @bo = BusinessOffice.find(params[:id])
      @bo.prefecture_name = @prefectures.find{|p| p[1] == @bo.prefecture_id}[0]

      unless @bo.update_attributes(params[:business_office])
        raise HyacccException.new(ERR_DB)
      end
      
      flash[:notice] = '事業所を更新しました。'
      render :partial=>'common/reload_dialog'
    rescue Exception => e
      handle(e)
      render :action => 'edit'
    end
  end
  
  def destroy
    begin
      setup_view_attributes
      @bo = BusinessOffice.find(params[:id])

      unless @bo.destroy
        raise HyacccException.new(ERR_DB)
      end
      
      flash[:notice] = '事業所を削除しました。'
    rescue Exception => e
      handle(e)
    end
    
    redirect_to :controller=>:company
  end

private
  def setup_view_attributes
    @prefectures = get_prefectures.collect{|p| [p[:name], p[:id]]}
  end
end
