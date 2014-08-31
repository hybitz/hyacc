module Base
  class HyaccController < ApplicationController
    include HyaccConstants
    include HyaccErrors
    include HyaccUtil
    include SessionHelper
    include ViewAttributeHandler
    include ExceptionHandler

    before_filter :check_first_boot
    before_filter :check_login_status
    before_filter :load_view_attributes

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
      if User.count == 0 and Company.count == 0
        redirect_to :controller => 'first_boot' and return
      end
    end
  
    def check_login_status
      unless current_user or controller_name == 'sessions'
        session[:jump_to] = params
        redirect_to new_session_path and return
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
