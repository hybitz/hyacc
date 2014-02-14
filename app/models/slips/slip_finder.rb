# coding: UTF-8
#
# $Id: slip_finder.rb 3025 2013-05-31 17:02:36Z ichy $
# Product: hyacc
# Copyright 2009-2013 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module Slips

  class SlipFinder < Base::Finder
    include JournalUtil

    attr_accessor :account_code
    attr_accessor :offset
    attr_accessor :prev_offset
    attr_accessor :next_offset
    attr_accessor :keep_paging
    
    def initialize( user )
      super( user )
      @sub_account_id_map = {}
    end
    
    def setup_from_params( params )
      if params
        @keep_paging = params[:keep_paging] == 'true'
      else
        @keep_paging = false
      end
    
      # ページングを維持する場合は検索条件の変更をしない
      if @keep_paging
        @offset = params[:offset]
      # ページングを維持しないならオフセットをリセット
      else
        # 画面上の検索条件を入力して表示ボタン押下の場合、検索条件を変更する
        if params
          super( params )
          @deleted = params[:deleted] # 親クラスの定義をオーバーライド
          put_sub_account_id(params[:sub_account_id].to_i)
        end
        
        @offset = nil
        @prev_offset = nil
        @next_offset = nil
      end
      
      # 補助科目の指定がない場合は、先頭の補助科目を検索条件にする
      account = Account.get_by_code( @account_code )
      if account.sub_accounts.empty?
        put_sub_account_id(0)
      else
        if get_sub_account_id == 0
          if account.sub_account_type == SUB_ACCOUNT_TYPE_EMPLOYEE
            put_sub_account_id(login_user_id)
          else
            put_sub_account_id(account.sub_accounts[0].id)
          end
        end
      end
    end

    def find( *args )
      journals = JournalHeader.find( *args )
      if journals.respond_to? :each
        ret = []

        journals.each do |jh|
          ret << Slip.new( jh, self )
        end

        return ret
      else
        return Slip.new( journals, self )
      end
    end
    
    def count( *args )
      JournalHeader.count( *args )
    end

    def get_net_sum
      super( account_code )
    end
    
    def get_net_sum_until( slip )
      super( slip, account_code )
    end
        
    # 伝票を検索する
    def list
      conditions = get_conditions

      # 条件に該当する総伝票数を取得
      total_count = count(:id, :conditions=>conditions)
      
      # 前伝票ページングのためのオフセットを計算
      prev_count = total_count - offset.to_i - slips_per_page
      if prev_count <= 0
        self.prev_offset = nil
      elsif prev_count < slips_per_page
        self.prev_offset = total_count - slips_per_page
      else
        self.prev_offset = offset.to_i + slips_per_page
      end
      
      # 次伝票ページングのためのオフセットを計算
      if offset.to_i == 0
        self.next_offset = nil
      elsif offset.to_i <  slips_per_page
        self.next_offset = 0
      else
        self.next_offset = offset.to_i - slips_per_page
      end

      # 条件に該当する伝票を取得
      find(
        :all,
        :conditions=>conditions,
        :include=>[:journal_details],
        :order=>"journal_headers.ym desc, journal_headers.day desc, journal_headers.created_on desc",
        :limit=> ym.to_i == 0 ? slips_per_page : nil,
        :offset=> offset.to_i).reverse
    end
    
  private
    def get_sub_account_id
      @sub_account_id = @sub_account_id_map[account_code].to_i
    end
    
    def put_sub_account_id(sub_account_id)
      @sub_account_id = sub_account_id
      @sub_account_id_map[account_code] = @sub_account_id
    end
  
    # 伝票検索条件を生成する
    def get_conditions()
      conditions = []
      
      # 伝票区分は簡易入力もしくは一般振替、台帳登録
      conditions[0] = "slip_type in ( ?, ?, ?, ? ) " if branch_id > 0
      conditions[0] = "slip_type in ( ?, ?, ?) " if branch_id == 0
      conditions << SLIP_TYPE_SIMPLIFIED
      conditions << SLIP_TYPE_TRANSFER
      conditions << SLIP_TYPE_AUTO_TRANSFER_LEDGER_REGISTRATION
      conditions << SLIP_TYPE_TEMPORARY_DEBT if branch_id > 0

      
      conditions[0] << "and finder_key rlike ? "
      conditions << build_rlike_condition( account_code, sub_account_id, branch_id )

      # 年月は任意
      if ym.to_i > 0
        conditions[0] << "and journal_headers.ym >= ? and journal_headers.ym <= ? "
        conditions << ym
        conditions << ym
      end
      
      # 摘要は任意
      unless remarks.nil?
        conditions[0] << "and journal_headers.remarks like ? "
        conditions << '%' + remarks + '%'
      end
      
      conditions
    end
    
  end
end
