# coding: UTF-8
#
# $Id: hyacc_controller.rb 3295 2014-01-24 01:03:37Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module Base
  class HyaccController < ApplicationController
    include HyaccConstants
    include HyaccErrors
    include HyaccUtil
    include SessionHelper
    include ViewAttributeHandler
    include ExceptionHandler
    include AclHandler
  
    before_filter :check_first_boot
    before_filter :check_login_status
    before_filter :load_view_attributes
  
    def index
      redirect_to :action => :list
    end

    # 会社の形態によりコントローラが利用可能かを確認する
    # return true  利用可能
    #        false 利用不可能
    def is_available_controller?(user)
      is_available?(controller_name, user, @@acl_table)
    end
  
  protected
    # 画面表示に必要なデータを定義しているテーブル
    @@attribute_table = {}
    # アクセス制限を定義しているテーブル
    @@acl_table = {}
    
    def self.view_attribute(attribute_name, options = {})
      if attribute_name.is_a? Hash
        options = attribute_name
        attribute_name = attribute_name.to_a[0][0]
      end

      @@attribute_table[controller_name] = {} unless @@attribute_table[controller_name]
      @@attribute_table[controller_name][attribute_name] = options
    end
    
    def get_attributes
      @@attribute_table[controller_name] = {} unless @@attribute_table[controller_name]
      @@attribute_table[controller_name]
    end
    
    def get_attribute(attribute_name)
      get_attributes()[attribute_name]
    end
    
    def self.available_for(options)
      @@acl_table[controller_name] = [] unless @@acl_table[controller_name]
      @@acl_table[controller_name] << options
    end

    def finder
      # ファインダー指定のないアクションの場合はセッション上のファインダーを利用する
      unless @finder
        attribute = get_attribute(:finder)
        session_key = attribute[:class] if attribute
        @finder = session[session_key.name] if session_key
      end
      
      @finder
    end
  
    # インストールほやほやかどうかチェックする
    def check_first_boot
      if User.count(:all) == 0 and Company.count(:all) == 0
        redirect_to :controller=>'first_boot' and return
      end
    end
  
    def check_login_status
      unless current_user or controller_name == 'login'
        session[:jump_to] = params
        redirect_to :controller => 'login' and return
      end
      
      unless is_available_controller?(current_user)
        reset_session
        redirect_to :controller => 'login' and return
      end

      # メニューのロゴ表示用
      @company = current_user.company if current_user
    end
  
    def find_sub_accounts_by_account_id
      account_id = params[:account_id].to_i
      if account_id > 0
        # 補助科目選択用リスト
        account = Account.find( account_id )
        unless account.nil?
          return account.sub_accounts
        end
      end
  
      return []
    end
  
    # 資本金を取得する
    def get_capital_stock( fiscal_year )
      rf = ReportFinder.new(current_user)
      rf.setup_from_params(:fiscal_year=>fiscal_year)
      rf.get_net_sum_amount( Account.get_by_code( ACCOUNT_CODE_CAPITAL_STOCK ) )
    end
  end
end
