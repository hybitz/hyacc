module Slips
  class Slip
    include HyaccConstants
    include AssetUtil

    # 入力フィールド
    attr_accessor :id
    attr_accessor :ym
    attr_accessor :day
    attr_accessor :remarks
    attr_accessor :account_id
    attr_accessor :account_code
    attr_accessor :account_name
    attr_accessor :branch_id
    attr_accessor :branch_name
    attr_accessor :sub_account_id
    attr_accessor :sub_account_name
    attr_accessor :amount_increase
    attr_accessor :amount_decrease
    attr_accessor :tax_type
    attr_accessor :tax_rate_percent
    attr_accessor :tax_amount_increase
    attr_accessor :tax_amount_decrease
    attr_accessor :slip_amount_increase
    attr_accessor :slip_amount_decrease
    attr_accessor :auto_journal_type
    attr_accessor :auto_journal_year
    attr_accessor :auto_journal_month
    attr_accessor :auto_journal_day
    attr_accessor :lock_version

    # 接待交際費用の入力フィールド
    attr_accessor :social_expense_number_of_people

    # 法人税の決算区分の入力フィールド
    attr_accessor :settlement_type

    # 資産管理用の入力フィールド
    attr_accessor :asset_id
    attr_accessor :asset_code
    attr_accessor :asset_lock_version

    # ARモデル
    attr_accessor :user
    attr_reader :journal

    # 簡易入力が前提としている勘定科目、補助科目
    attr_accessor :my_account_id
    attr_accessor :my_sub_account_id

    def initialize(*args)
      # 第1引数が伝票ヘッダの場合
      if args[0].is_a? Journal
        @journal = args[0]
        setup_from_journal(args[1])
      # 第1引数がハッシュの場合(通常は画面入力）
      elsif args[0].is_a? Hash
        @journal = Journal.new
        setup_from_params(args[0])
      else
        raise HyaccException.new(args[0].class)
      end
    end

    def new_record?
      @journal.new_record?
    end

    def errors
      @journal.errors
    end

    def journal_details
      @journal.journal_details
    end

    # 簡易入力機能で編集可能かどうか
    def editable?
      SlipUtils.editable_as_simple_slip(@journal, @my_account_id)
    end

    def destroy
      # 締め状態の確認
      JournalUtil.validate_closing_status_on_delete( @journal )

      # 資産チェック
      validate_assets( nil, @journal )

      @journal.lock_version = lock_version
      @journal.destroy
    end

    # 自動振替伝票があるか
    def has_auto_transfers
      @journal.has_auto_transfers
    end

    private

    def setup_from_journal( slip_finder )
      my_account = Account.find_by_code(slip_finder.account_code)
      @my_account_id = my_account.id

      @id = @journal.id
      @ym = @journal.ym
      @day = @journal.day
      @remarks = @journal.remarks
      @lock_version = @journal.lock_version

      if editable?
        # 本伝票が前提としている科目側の明細を取得
        my_detail = journal_details.find{|jd| jd.account_id == @my_account_id.to_i && jd.detail_type == DETAIL_TYPE_NORMAL}

        # 本伝票が前提としている科目側の補助科目を設定
        @my_sub_account_id = my_detail.sub_account_id

        # ユーザ入力科目側の明細を取得
        target_detail = journal_details.where('account_id <> ? and detail_type = ?', @my_account_id, DETAIL_TYPE_NORMAL).first
        @account_id = target_detail.account_id
        @account_name = target_detail.account_name
        @account_code = target_detail.account.code
        @branch_id = target_detail.branch_id
        @branch_name = target_detail.branch_name
        @sub_account_id = target_detail.sub_account_id
        @sub_account_name = target_detail.sub_account_name

        # 消費税税区分、消費税率
        @tax_type = target_detail.tax_type
        @tax_rate_percent = target_detail.tax_rate_percent

        # 金額、消費税額
        if my_detail.dc_type == my_detail.account.dc_type
          @amount_increase = target_detail.amount
          if target_detail.tax_detail.nil?
            @tax_amount_increase = 0
          else
            @amount_increase += target_detail.tax_detail.amount if tax_type == TAX_TYPE_INCLUSIVE
            @tax_amount_increase = target_detail.tax_detail.amount
          end
        else
          @amount_decrease = target_detail.amount
          if target_detail.tax_detail.nil?
            @tax_amount_decrease = 0
          else
            @amount_decrease += target_detail.tax_detail.amount if tax_type == TAX_TYPE_INCLUSIVE
            @tax_amount_decrease = target_detail.tax_detail.amount
          end
        end

        # 接待交際費の参加人数
        @social_expense_number_of_people = target_detail.social_expense_number_of_people

        # 法人税の決算区分
        @settlement_type = target_detail.settlement_type

        # 固定資産の場合は資産コード、資産名をVOにセットする
        if target_detail.asset
          @asset_id = target_detail.asset.id
          @asset_code = target_detail.asset.code
          @asset_lock_version = target_detail.asset.lock_version
        end

      else
        various = Account.find_by_code( ACCOUNT_CODE_VARIOUS )
        @account_code = various.code
        @account_name = various.name
      end

      # 伝票金額を算出
      @slip_amount_increase = 0
      @slip_amount_decrease = 0
      journal_details.each do |jd|
        next if jd.account_id != @my_account_id
        next if slip_finder.sub_account_id.to_i > 0 and jd.sub_account_id != slip_finder.sub_account_id.to_i
        next if slip_finder.branch_id.to_i > 0 and jd.branch_id != slip_finder.branch_id.to_i

        if jd.dc_type == my_account.dc_type
          @slip_amount_increase += jd.amount
        else
          @slip_amount_decrease += jd.amount
        end
      end
    end

    def setup_from_params(hash = {})
      # 簡易入力が前提としている勘定科目、補助科目
      my_account = Account.find_by_code(hash[:account_code])
      @my_account_id = my_account.id
      @my_sub_account_id = hash[:my_sub_account_id].to_i

      @id = hash[:id].to_i
      @ym = hash[:ym]
      @day = hash[:day]
      @remarks = hash[:remarks]
      @account_id = hash[:account_id].to_i
      @branch_id = hash[:branch_id].to_i
      @sub_account_id = hash[:sub_account_id].to_i
      @amount_increase = hash[:amount_increase]
      @amount_decrease = hash[:amount_decrease]
      @tax_type = hash[:tax_type].to_i
      @tax_rate_percent = hash[:tax_rate_percent]
      @tax_amount_increase = hash[:tax_amount_increase]
      @tax_amount_decrease = hash[:tax_amount_decrease]
      @auto_journal_type = hash[:auto_journal_type].to_i
      @auto_journal_year = hash[:auto_journal_year]
      @auto_journal_month = hash[:auto_journal_month]
      @auto_journal_day = hash[:auto_journal_day]
      @social_expense_number_of_people = hash[:social_expense_number_of_people]
      @settlement_type = hash[:settlement_type]
      @lock_version = hash[:lock_version]

      # 資産管理入力フィールド
      @asset_id = hash[:asset_id].to_i
      @asset_lock_version = hash[:asset_lock_version]
    end
  end
end
