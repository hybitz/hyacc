# coding: UTF-8
#
# $Id: banks_controller.rb 3296 2014-01-24 04:00:10Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class BanksController < Base::BasicMasterController
  layout 'application'
  view_attribute :title=>'金融機関'
  view_attribute :finder, :class=>BankFinder, :only=>:index
  view_attribute :deleted_types
  view_attribute :model, :class=>Bank

  def index
    @banks = finder.list
  end

  def show
    @bank = Bank.find(params[:id])
  end

  def new
    @bank = Bank.new
  end

  def edit
    @bank = Bank.find(params[:id])
  end

  def create
    @bank = Bank.new(params[:bank])

    begin
      @bank.transaction do
        @bank.save!
      end

      flash[:notice] = '金融機関を登録しました。'
      render 'common/reload'
    
    rescue Exception => e
      handle(e)
      render :new
    end
  end

  def update
    @bank = Bank.find(params[:id])

    begin
      @bank.transaction do
        @bank.update_attributes!(params[:bank])
      end

      flash[:notice] = '金融機関を更新しました。'
      render 'common/reload'
      
    rescue Exception => e
      handle(e)
      render :edit
    end
  end

end
