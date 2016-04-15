module Slips

  class Slip
    include JournalUtil
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
    attr_reader :journal_header

    # 簡易入力が前提としている勘定科目、補助科目
    attr_accessor :my_account_id
    attr_accessor :my_sub_account_id

    def initialize(*args)
      # 第1引数が伝票ヘッダの場合
      if args[0].is_a? JournalHeader
        @journal_header = args[0]
        setup_from_journal(args[1])
      # 第1引数がハッシュの場合(通常は画面入力）
      elsif args[0].is_a? Hash
        @journal_header = JournalHeader.new
        setup_from_params(args[0])
      else
        raise HyaccException.new(args[0].class)
      end
    end

    def new_record?
      @journal_header.new_record?
    end

    def errors
      @journal_header.errors
    end

    def journal_details
      @journal_header.journal_details
    end

    # 簡易入力機能で編集可能かどうか
    def editable?
      SlipUtils.editable_as_simple_slip(@journal_header, @my_account_id)
    end

    def create
      @journal_header.transaction do
        @journal_header.company_id = @user.company.id
        @journal_header.ym = ym
        @journal_header.day = day
        @journal_header.remarks = remarks
        @journal_header.slip_type = SLIP_TYPE_SIMPLIFIED
        @journal_header.create_user_id = user.id
        @journal_header.update_user_id = user.id
        @journal_header.journal_details = create_details()

        # 簡易入力で入力可能な状態のデータであることを確認
        raise HyaccException.new(ERR_INVALID_SLIP) unless editable?

        # 登録
        @journal_header.save!

        # 資産チェック
        validate_assets( @journal_header, nil )

        # 自動仕訳を作成
        do_auto_transfers( @journal_header )

        # 仕訳チェック
        validate_journal( @journal_header, nil )

        # 登録
        @journal_header.save!

        return self
      end
    end

    def update( params )
      setup_from_params( params )
      old = @journal_header.copy

      @journal_header.transaction do
        @journal_header.ym = @ym
        @journal_header.day = @day
        @journal_header.remarks = @remarks
        @journal_header.slip_type = SLIP_TYPE_SIMPLIFIED
        @journal_header.update_user_id = @user.id
        @journal_header.lock_version = @lock_version
        @journal_header.journal_details = create_details

        # 簡易入力で入力可能な状態のデータであることを確認
        unless editable?
          raise HyaccException.new(ERR_INVALID_SLIP)
        end

        # 資産チェック
        validate_assets( @journal_header, old )

        # 自動仕訳を作成
        do_auto_transfers( @journal_header )

        # 仕訳チェック
        validate_journal( @journal_header, old )

        # 更新
        @journal_header.save!

        return self
      end
    end

    def destroy
      # 締め状態の確認
      validate_closing_status_on_delete( @journal_header )

      # 資産チェック
      validate_assets( nil, @journal_header )

      @journal_header.lock_version = lock_version
      @journal_header.destroy
    end

    # 自動振替伝票があるか
    def has_auto_transfers
      @journal_header.has_auto_transfers
    end

    private

    # 仕訳明細の作成
    def create_details
      account = Account.get( @my_account_id )
      target_account = Account.get( @account_id )
      amount = @amount_increase.to_i > 0 ? @amount_increase.to_i : @amount_decrease.to_i
      tax_amount = @amount_increase.to_i > 0 ? @tax_amount_increase.to_i : @tax_amount_decrease.to_i

      ret = []

      # この簡易入力が扱っている科目
      jd1 = clear_detail_attributes journal_details[0]
      jd1.journal_header = @journal_header
      jd1.detail_no = 1
      jd1.detail_type = DETAIL_TYPE_NORMAL
      jd1.dc_type = amount_increase.to_i > 0 ? account.dc_type : opposite_dc_type( account.dc_type )
      jd1.tax_type = TAX_TYPE_NONTAXABLE
      jd1.tax_rate_percent = 0
      jd1.account_id = account.id
      jd1.branch_id = @user.company.branch_mode ? @branch_id : @user.employee.default_branch.id
      jd1.sub_account_id = @my_sub_account_id if @my_sub_account_id > 0
      jd1.amount = calc_amount(@tax_type, amount, tax_amount) + tax_amount
      ret << jd1

      # 入力された科目
      jd2 = clear_detail_attributes journal_details[1]
      jd2.journal_header = @journal_header
      jd2.detail_no = 2
      jd2.detail_type = DETAIL_TYPE_NORMAL
      jd2.dc_type = opposite_dc_type( jd1.dc_type )
      jd2.tax_type = @tax_type
      jd2.tax_rate_percent = @tax_rate_percent
      jd2.account_id = target_account.id
      jd2.branch_id = jd1.branch_id
      jd2.sub_account_id = sub_account_id if sub_account_id > 0
      jd2.amount = calc_amount(@tax_type, amount, tax_amount)

      # 接待交際費の参加人数
      jd2.social_expense_number_of_people = target_account.is_social_expense ? @social_expense_number_of_people : nil

      # 法人税の決算区分
      jd2.settlement_type = target_account.is_corporate_tax ? @settlement_type : nil

      # 計上日振替の設定
      jd2.auto_journal_type = @auto_journal_type
      jd2.auto_journal_year = @auto_journal_year
      jd2.auto_journal_month = @auto_journal_month
      jd2.auto_journal_day = @auto_journal_day

      # 資産の楽観ロック
      jd2.asset.lock_version = @asset_lock_version if jd2.asset

      ret << jd2

      # 税抜経理方式で消費税があれば、消費税明細を自動仕訳
      if tax_amount > 0
        jd3 = clear_detail_attributes journal_details[2]
        jd3.journal_header = @journal_header
        jd3.detail_no = 3
        jd3.detail_type = DETAIL_TYPE_TAX
        jd3.dc_type = jd2.dc_type
        jd3.tax_type = TAX_TYPE_NONTAXABLE
        jd3.tax_rate_percent = 0

        # 借方の場合は仮払消費税
        if target_account.dc_type == DC_TYPE_DEBIT
          jd3.account_id = Account.get_by_code( ACCOUNT_CODE_TEMP_PAY_TAX ).id
        # 貸方の場合は借受消費税
        elsif target_account.dc_type == DC_TYPE_CREDIT
          jd3.account_id = Account.get_by_code( ACCOUNT_CODE_SUSPENSE_TAX_RECEIVED ).id
        end

        jd3.branch_id = jd2.branch_id
        jd3.amount = tax_amount

        # 対象の明細との関連を設定
        jd3.main_detail = jd2

        ret << jd3
      end

      return ret
    end

    # 自動振替仕訳の作成
    def do_auto_transfers( jh )
      slip_types = [
        SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE,
        SLIP_TYPE_AUTO_TRANSFER_ACCRUED_EXPENSE,
        SLIP_TYPE_AUTO_TRANSFER_EXPENSE]
      clear_auto_journals(jh, slip_types)

      # ユーザが入力した科目側の明細に対して振替仕訳を作成する
      target_jd = nil
      jh.journal_details.each do |jd|
        if jd.account_id != @my_account_id
          if jd.detail_type == DETAIL_TYPE_NORMAL
            target_jd = jd
            break
          end
        end
      end
      raise HyaccException.new(ERR_INVALID_SLIP) unless target_jd

      param = Auto::TransferJournal::TransferFromDetailParam.new( @auto_journal_type, target_jd )
      factory = Auto::AutoJournalFactory.get_instance( param )
      factory.make_journals()
    end

    def has_accrued_expense_transfers
      journals = get_all_related_journals(@journal_header)
      return false if journals.size != 3
      return false if journals[1].slip_type != SLIP_TYPE_AUTO_TRANSFER_ACCRUED_EXPENSE
      return false if journals[2].slip_type != SLIP_TYPE_AUTO_TRANSFER_ACCRUED_EXPENSE
      true
    end

    def has_date_input_expense_transfers
      journals = get_all_related_journals(@journal_header)
      return false if journals.size != 3
      return false if journals[1].slip_type != SLIP_TYPE_AUTO_TRANSFER_EXPENSE
      return false if journals[2].slip_type != SLIP_TYPE_AUTO_TRANSFER_EXPENSE
      true
    end

    def has_prepaid_expense_transfers
      journals = get_all_related_journals(@journal_header)
      return false if journals.size != 3
      return false if journals[1].slip_type != SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE
      return false if journals[2].slip_type != SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE
      true
    end

    def setup_from_journal( slip_finder )
      my_account = Account.get_by_code(slip_finder.account_code)
      @my_account_id = my_account.id

      @id = @journal_header.id
      @ym = @journal_header.ym
      @day = @journal_header.day
      @remarks = @journal_header.remarks
      @lock_version = @journal_header.lock_version

      if has_prepaid_expense_transfers
        @auto_journal_type = AUTO_JOURNAL_TYPE_PREPAID_EXPENSE
      elsif has_accrued_expense_transfers
        @auto_journal_type = AUTO_JOURNAL_TYPE_ACCRUED_EXPENSE
      elsif has_date_input_expense_transfers
        @auto_journal_type = AUTO_JOURNAL_TYPE_DATE_INPUT_EXPENSE

        journals = get_all_related_journals(@journal_header)
        if journals[0].date != journals[1].date
          @auto_journal_year = journals[1].date.year
          @auto_journal_month = journals[1].date.month
          @auto_journal_day = journals[1].date.day
        else
          @auto_journal_year = journals[2].date.year
          @auto_journal_month = journals[2].date.month
          @auto_journal_day = journals[2].date.day
        end
      end

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
        various = Account.get_by_code( ACCOUNT_CODE_VARIOUS )
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
      my_account = Account.get_by_code(hash[:account_code])
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
