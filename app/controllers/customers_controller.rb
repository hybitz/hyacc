# coding: UTF-8
#
# $Id: customers_controller.rb 3338 2014-01-31 03:52:13Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class CustomersController < Base::HyaccController
  view_attribute :title => '取引先'
  view_attribute :finder, :class => CustomerFinder, :only => :index
  view_attribute :deleted_types
  
  def add_customer_name
    @customer_name = CustomerName.new
  end

  def index
    @customers = finder.list

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @customers }
    end
  end

  def show
    @customer = Customer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @customer }
    end
  end

  def new
    @customer = Customer.new
    @customer.customer_names << CustomerName.new
  end

  def edit
    @customer = Customer.find(params[:id])
  end

  def create
    begin
      @customer = Customer.new(params[:customer])
      @customer.customer_names[0].start_date = current_user.company.founded_date

      @customer.transaction do
        @customer.save!
      end

      flash[:notice] = '取引先を登録しました。'
      render 'common/reload'

    rescue Exception=>e
      handle(e)
      render 'new'
    end
  end

  def update
    begin
      # 取引先コードの更新は不可
      params[:customer].delete( :code ) if params[:customer]
  
      @customer = Customer.find(params[:id])
      
      @customer.transaction do
        @customer.attributes = params[:customer]
        @customer.save!
        flash[:notice] = '取引先を更新しました。'
        render :partial=>'common/reload_dialog'
      end
    rescue Exception=>e
      handle(e)
      render :action => :edit
    end
  end

  def destroy
    @customer = Customer.find(params[:id])
    @customer.deleted = true
    @customer.save!
    respond_to do |format|
      flash[:notice] = '取引先を削除しました。'
      format.html { redirect_to(:action=>:index) }
      format.xml  { head :ok }
    end
  end
end
