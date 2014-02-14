# coding: UTF-8
#
# $Id: bank_offices_controller.rb 2899 2012-08-31 02:38:30Z ichy $
# Product: hyacc
# Copyright 2009-2012 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class BankOfficesController < Base::BasicMasterController
  view_attribute :deleted_types
  
  def add_bank_office
    @bank_office = BankOffice.new
  end  
  
  # GET /bank_offices
  # GET /bank_offices.xml
  def index
    @bank_offices = BankOffice.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bank_offices }
    end
  end

  # GET /bank_offices/1
  # GET /bank_offices/1.xml
  def show
    @bank_office = BankOffice.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @bank_office }
    end
  end

  # GET /bank_offices/new
  # GET /bank_offices/new.xml
  def new
    @bank_office = BankOffice.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @bank_office }
    end
  end

  # GET /bank_offices/1/edit
  def edit
    @bank_office = BankOffice.find(params[:id])
  end

  # POST /bank_offices
  # POST /bank_offices.xml
  def create
    @bank_office = BankOffice.new(params[:bank_office])

    respond_to do |format|
      if @bank_office.save
        flash[:notice] = 'BankOffice was successfully created.'
        format.html { redirect_to(@bank_office) }
        format.xml  { render :xml => @bank_office, :status => :created, :location => @bank_office }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @bank_office.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bank_offices/1
  # PUT /bank_offices/1.xml
  def update
    @bank_office = BankOffice.find(params[:id])

    respond_to do |format|
      if @bank_office.update_attributes(params[:bank_office])
        flash[:notice] = 'BankOffice was successfully updated.'
        format.html { redirect_to(@bank_office) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bank_office.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bank_offices/1
  # DELETE /bank_offices/1.xml
  def destroy
    @bank_office = BankOffice.find(params[:id])
    @bank_office.destroy

    respond_to do |format|
      format.html { redirect_to(bank_offices_url) }
      format.xml  { head :ok }
    end
  end
end
