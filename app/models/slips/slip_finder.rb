module Slips

  class SlipFinder < Base::Finder
    include HyaccConstants

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

    def find(id)
      SimpleSlip.build_from_journal(Account.get_by_code(@account_code).id, id)
    end

    def get_net_sum
      JournalUtil.get_net_sum(company_id, account_code, branch_id, sub_account_id)
    end

    def get_net_sum_until(slip)
      JournalUtil.get_net_sum_until(slip, account_code, branch_id, sub_account_id)
    end

    # 伝票を検索する
    def list(options = {})
      per_page = options[:per_page] || slips_per_page

      conditions = get_conditions

      # 条件に該当する総伝票数を取得
      total_count = JournalHeader.where(conditions).count

      # 前伝票ページングのためのオフセットを計算
      prev_count = total_count - offset.to_i - per_page
      if prev_count <= 0
        self.prev_offset = nil
      elsif prev_count < per_page
        self.prev_offset = total_count - per_page
      else
        self.prev_offset = offset.to_i + per_page
      end

      # 次伝票ページングのためのオフセットを計算
      if offset.to_i == 0
        self.next_offset = nil
      elsif offset.to_i <  per_page
        self.next_offset = 0
      else
        self.next_offset = offset.to_i - per_page
      end

      # 条件に該当する伝票を取得
      journal_headers = JournalHeader.where(conditions).includes(:journal_details, :receipt)
            .order('journal_headers.ym desc, journal_headers.day desc, journal_headers.id desc')
            .limit(ym.to_i == 0 ? per_page : nil).offset(offset.to_i).reverse
      journal_headers.map{|jh| Slip.new(jh, self) }
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
    def get_conditions
      sql = SqlBuilder.new
       # 伝票区分の指定
      sql.append('slip_type in ( ? )', EXTERNAL_SLIP_TYPES.merge(BRANCH_SLIP_TYPES).keys) if branch_id > 0
      sql.append('slip_type in ( ? )', EXTERNAL_SLIP_TYPES.keys) if branch_id == 0
      sql.append('and finder_key rlike ?', JournalUtil.build_rlike_condition(account_code, sub_account_id, branch_id))

      # 年月は任意
      normalized_ym = ym.to_s.length > 6 ? ym[0..3] + ym[-2..-1] : nil
      if normalized_ym
        sql.append('and journal_headers.ym >= ? and journal_headers.ym <= ?', normalized_ym, normalized_ym)
      end

      # 摘要は任意
      sql.append('and journal_headers.remarks like ?', '%' + remarks + '%') if remarks.present?

      sql.to_a
    end

  end
end
