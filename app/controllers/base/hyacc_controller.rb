module Base
  class HyaccController < ApplicationController
    include HyaccConstants
    include HyaccErrors
    include ViewAttributeHandler
    include ExceptionHandler
    include CurrentCompany
    include YmdInputState

    before_filter :check_first_boot
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

    # 資本金を取得する
    def get_capital_stock( fiscal_year )
      stock = Account.get_by_code(ACCOUNT_CODE_CAPITAL_STOCK)

      rf = ReportFinder.new(current_user)
      rf.setup_from_params(:fiscal_year => fiscal_year)
      rf.get_net_sum(stock)
    end
  end
end
