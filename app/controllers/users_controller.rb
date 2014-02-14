# coding: UTF-8
#
# $Id: users_controller.rb 3295 2014-01-24 01:03:37Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class UsersController < Base::HyaccController
  view_attribute :title => 'ユーザ'
  view_attribute :accounts, :except=>[:list, :show, :destroy],
    :conditions=>['account_type in (?, ?) and journalizable=? and tax_type=? and deleted=?',
      ACCOUNT_TYPE_ASSET, ACCOUNT_TYPE_DEBT, true, TAX_TYPE_NONTAXABLE, false]
         
  def add_simple_slip_setting
    sss = SimpleSlipSetting.new(:user_id => params[:user_id], :shortcut_key => 'Ctrl+')
    render :partial => 'simple_slip_setting_fields', :locals => {:sss => sss, :index => params[:index]}
  end

  def index
    @users = User.paginate :page=>params[:page], :per_page=>20
  end

  def show
    @user = User.find(params[:id], :include=>:employee)
  end

  def new
    @user = User.new
    @user.employee = Employee.new
  end

  def create
    @user = User.new(params[:user])

    begin
      @user.transaction do
        @user.company_id = @user.employee.company_id = current_user.company_id
        @user.save!
      end

      flash[:notice] = 'ユーザを追加しました。'
      render 'common/reload'

    rescue Exception => e
      handle(e)
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    # ログインIDの更新は不可
    params[:user].delete( :login_id ) if params[:user]

    @user = User.find(params[:id])
    begin
      @user.transaction do
        @user.update_attributes!(params[:user])
      
        flash[:notice] = 'ユーザを更新しました。'
        render 'common/reload'
      end
    rescue Exception => e
      handle(e)
      render :edit
    end
  end

  def destroy
    id = params[:id].to_i
    User.find(id).update_attributes!(:deleted=>true)

    # 削除したユーザがログインユーザ自身の場合は、ログアウト
    if current_user.id == id
      redirect_to :controller=>:login, :action=>:logout
    else
      flash[:notice] = 'ユーザを削除しました。'
      redirect_to :action=>:index
    end
  end
end
