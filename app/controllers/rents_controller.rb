# coding: UTF-8
#
# $Id: rents_controller.rb 2935 2012-10-19 06:13:24Z ichy $
# Product: hyacc
# Copyright 2009-2012 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class RentsController < Base::HyaccController
  layout 'application'
  before_filter :check_customer_exists
  view_attribute :title=>'地代家賃'
  view_attribute :finder, :class=>RentFinder, :only=>:index
  view_attribute :deleted_types

  # GET /rents
  # GET /rents.xml
  def index
    @rents = finder.list

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rents }
    end
  end

  # GET /rents/1
  # GET /rents/1.xml
  def show
    @rent = Rent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @rent }
    end
  end

  # GET /rents/new
  # GET /rents/new.xml
  def new
    @rent = Rent.new
    @customers = Customer.find(:all, :conditions=>"deleted=false")
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @rent }
    end
  end

  # GET /rents/1/edit
  def edit
    @rent = Rent.find(params[:id])
    @customers = Customer.find(:all, :conditions=>"deleted=false")
  end

  def create
    @rent = Rent.new(params[:rent])

    begin
      Rent.transaction do
        @rent.save!
      end

      flash[:notice] = '地代家賃を登録しました。'
      render :partial=>'common/reload_dialog'

    rescue Exception => e
      handle(e)
      @customers = Customer.where(:deleted => false)
      render :action => "new"
    end
  end

  # PUT /rents/1
  # PUT /rents/1.xml
  def update
    @rent = Rent.find(params[:id])

    respond_to do |format|
      if @rent.update_attributes(params[:rent])
        flash[:notice] = '地代家賃を更新しました。'
        format.html {
          render :partial=>'common/reload_dialog'
         }
        format.xml  { head :ok }
      else
        # TODO @customersの宣言をview_attributeに移行
        @customers = Customer.find(:all, :conditions=>"deleted=false")
        format.html { render :action => "edit" }
        format.xml  { render :xml => @rent.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /rents/1
  # DELETE /rents/1.xml
  def destroy
    @rent = Rent.find(params[:id])
    @rent.destroy

    respond_to do |format|
      format.html { redirect_to(rents_url) }
      format.xml  { head :ok }
    end
  end
  
private
  def check_customer_exists
    if Customer.count(:all) == 0
      render :check_customer_exists and return
    end
  end
end
