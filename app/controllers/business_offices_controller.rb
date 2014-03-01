# coding: UTF-8
#
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class BusinessOfficesController < Base::HyaccController
  view_attribute :title => '事業所'
  before_filter :setup_view_attributes

  def new
    @bo = BusinessOffice.new(:company_id => params[:company_id])
  end

  def create
    begin
      @bo = BusinessOffice.new(params[:business_office])
      @bo.transaction do
        @bo.prefecture_name = @prefectures.find{|p| p[1] == @bo.prefecture_id}[0]
        @bo.save!
      end

      flash[:notice] = '事業所を登録しました。'
      render 'common/reload'

    rescue => e
      handle(e)
      render :action => 'new'
    end
  end
  
  def edit
    @bo = BusinessOffice.find(params[:id])
  end
  
  def update
    begin
      @bo = BusinessOffice.find(params[:id])
      @bo.transaction do
        @bo.attributes = params[:business_office]
        @bo.prefecture_name = @prefectures.find{|p| p[1] == @bo.prefecture_id}[0]
        @bo.save!
      end
      
      flash[:notice] = '事業所を更新しました。'
      render 'common/reload'
    rescue => e
      handle(e)
      render :action => 'edit'
    end
  end
  
  def destroy
    begin
      @bo = BusinessOffice.find(params[:id])

      unless @bo.destroy
        raise HyacccException.new(ERR_DB)
      end
      
      flash[:notice] = '事業所を削除しました。'
    rescue => e
      handle(e)
    end
    
    redirect_to :controller=>:company
  end

  private

  def setup_view_attributes
    @prefectures = get_prefectures.collect{|p| [p[:name], p[:id]]}
  end

end
