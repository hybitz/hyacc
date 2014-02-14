# coding: UTF-8
#
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class RentsController < Base::HyaccController
  before_filter :check_customer_exists
  view_attribute :title => '地代家賃'
  view_attribute :finder, :class => RentFinder, :only => :index
  view_attribute :deleted_types

  def index
    @rents = finder.list
  end

  def show
    @rent = Rent.find(params[:id])
  end

  def new
    @rent = Rent.new
    @customers = Customer.not_deleted
  end

  def edit
    @rent = Rent.find(params[:id])
    @customers = Customer.not_deleted
  end

  def create
    @rent = Rent.new(params[:rent])

    begin
      Rent.transaction do
        @rent.save!
      end

      flash[:notice] = '地代家賃を登録しました。'
      render 'common/reload'

    rescue Exception => e
      handle(e)
      @customers = Customer.not_deleted
      render :action => "new"
    end
  end

  def update
    @rent = Rent.find(params[:id])

    if @rent.update_attributes(params[:rent])
      flash[:notice] = '地代家賃を更新しました。'
      render 'common/reload'
    else
      @customers = Customer.not_deleted
      render :action => "edit"
    end
  end

  def destroy
    @rent = Rent.find(params[:id])
    @rent.destroy

    redirect_to :action => 'index'
  end
  
  private

  def check_customer_exists
    if Customer.count == 0
      render :check_customer_exists and return
    end
  end
end
