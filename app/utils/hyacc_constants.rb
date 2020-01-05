module HyaccConstants

  # 勘定科目区分
  ACCOUNT_TYPES = {
    ACCOUNT_TYPE_ASSET = 1 => '資産',
    ACCOUNT_TYPE_DEBT = 2 => '負債',
    ACCOUNT_TYPE_CAPITAL = 3 => '資本',
    ACCOUNT_TYPE_PROFIT = 4 => '収益',
    ACCOUNT_TYPE_EXPENSE = 5 => '費用',
  }

  # 配賦区分
  ALLOCATION_TYPES = {
    ALLOCATION_TYPE_EVEN_BY_SIBLINGS = 1 => '同列部門に均等に',
    ALLOCATION_TYPE_SHARE_BY_EMPLOYEE = 2 => '社員数に応じて',
    ALLOCATION_TYPE_EVEN_BY_CHILDREN = 3 => '子部門に均等に',
  }

  # 承認ステータス
  APPROVAL_STATUS = {
    APPROVAL_STATUS_NOT_APPROVED = 1 => '未承認',
    APPROVAL_STATUS_APPROVED = 2 => '承認済',
    APPROVAL_STATUS_REJECTED = 3 => '承認却下',
  }

  # 資産ステータス
  ASSET_STATUS = {
    ASSET_STATUS_CREATED = 1 => '登録済',
    ASSET_STATUS_WAITING = 2 => '償却待',
    ASSET_STATUS_DEPRECIATING = 3 => '償却中',
    ASSET_STATUS_DEPRECIATED = 4 => '償却済',
  }

  # 自動仕訳区分
  AUTO_JOURNAL_TYPES = {
    AUTO_JOURNAL_TYPE_PREPAID_EXPENSE = 1 => 'TransferJournal::PrepaidExpenseFactory',
    AUTO_JOURNAL_TYPE_ACCRUED_EXPENSE = 2 => 'TransferJournal::AccruedExpenseFactory',
    AUTO_JOURNAL_TYPE_DATE_INPUT_EXPENSE = 3 => 'TransferJournal::ExpenseFactory',
    AUTO_JOURNAL_TYPE_INTERNAL_TRADE = 4 => 'TransferJournal::InternalTradeFactory',
    AUTO_JOURNAL_TYPE_ALLOCATED_COST = 5 => 'TransferJournal::AllocatedCostFactory',
    AUTO_JOURNAL_TYPE_DEPRECIATION = 6 => 'Journal::DepreciationFactory',
    AUTO_JOURNAL_TYPE_PAYROLL = 7 => 'Journal::PayrollFactory',
    AUTO_JOURNAL_TYPE_ALLOCATED_ASSETS = 8 => 'TransferJournal::AllocatedAssetsFactory',
    AUTO_JOURNAL_TYPE_TEMPORARY_DEBT = 9 => 'Journal::TemporaryDebtFactory',
    AUTO_JOURNAL_TYPE_DEEMED_TAX = 12 => 'Journal::DeemedTaxFactory',
    AUTO_JOURNAL_TYPE_INVESTMENT = 13 => 'Journal::InvestmentFactory',
  }

  # 締め状態
  CLOSING_STATUS = {
    CLOSING_STATUS_OPEN = 1 => '通常',
    CLOSING_STATUS_CLOSING = 2 => '仮締',
    CLOSING_STATUS_CLOSED = 3 => '本締',
  }

  # 消費税申告区分
  CONSUMPTION_ENTRY_TYPES = {
    CONSUMPTION_ENTRY_TYPE_GENERAL = 1 => '一般用',
    CONSUMPTION_ENTRY_TYPE_SIMPLIFIED = 2 => '簡易課税用',
  }

  # 会社形態区分
  COMPANY_TYPES = {
    COMPANY_TYPE_COLTD = 1 => '株式会社',
    COMPANY_TYPE_GP = 2 => '合名会社',
    COMPANY_TYPE_LP = 3 => '合資会社',
    COMPANY_TYPE_LLC = 4 => '合同会社',
    COMPANY_TYPE_PRIVATE = 5 => '有限会社',
    COMPANY_TYPE_PERSONAL = 9 => '個人事業主',
  }
  
  # 法人税区分
  CORPORATE_TAX_TYPES = {
    CORPORATE_TAX_TYPE_CORPORATE_TAX = 1 => '法人税',
    CORPORATE_TAX_TYPE_PREFECTURAL_TAX = 2 => '道府県民税',
    CORPORATE_TAX_TYPE_MUNICIPAL_INHABITANTS_TAX = 3 => '市町村民税',
    CORPORATE_TAX_TYPE_RECONSTRUCTION_TAX = 4 => '復興税',
    CORPORATE_TAX_TYPE_REGIONAL_CORPORATE_TAX = 5 => '地方法人税'
  }

  DEFAULT_PAYDAY = "0,25"
  
  # 減価償却方法
  DEPRECIATION_METHODS = {
    DEPRECIATION_METHOD_FIXED_AMOUNT = 1 => '定額法',
    DEPRECIATION_METHOD_FIXED_RATE = 2 => '定率法',
    DEPRECIATION_METHOD_LUMP = 3 => '一括償却',
  }

  # 明細区分
  DETAIL_TYPES = {
    DETAIL_TYPE_NORMAL = 1 => '通常',
    DETAIL_TYPE_TAX = 2 => '消費税',
  }

  # 貸借区分
  DC_TYPES = {
    DC_TYPE_DEBIT = 1 => '借方',
    DC_TYPE_CREDIT = 2 => '貸方',
  }

  DEFAULT_PER_PAGE = 20

  # 削除区分
  DELETED_TYPES = {
    DELETED_TYPE_USE = false => '有効',
    DELETED_TYPE_STOP = true => '無効',
  }

  # 無効化区分
  DISABLE_TYPES = {
    ENABLED = false => '有効',
    DISABLED = true => '無効',
  }

  # 控除対象区分
  EXEMPTION_TYPES = {
    EXEMPTION_TYPE_SPOUSE = 1 => '控除対象配偶者',
    EXEMPTION_TYPE_FAMILY = 2 => '控除対象扶養親族',
    EXEMPTION_TYPE_UNDER_16 = 3 => '16歳未満扶養親族',
  }

  # 金融口座区分
  FINANCIAL_ACCOUNT_TYPES = {
    FINANCIAL_ACCOUNT_TYPE_SAVING = 1 => '普通預金', # 銀行口座
    FINANCIAL_ACCOUNT_TYPE_CHECKING = 2 => '当座預金', # 銀行口座
    FINANCIAL_ACCOUNT_TYPE_GENERAL = 3 => '一般口座', # 株式口座
    FINANCIAL_ACCOUNT_TYPE_SPECIFIC = 4 => '特定口座（源泉徴収なし）', # 株式口座（源泉徴収なし）
    FINANCIAL_ACCOUNT_TYPE_SPECIFIC_WITHHOLD = 5 => '特定口座（源泉徴収あり）', # 株式口座（源泉徴収あり）
  }
  
  # テンプレート適応後のフォーカス項目
  FOCUS_ON_COMPLETES = {
    FOCUS_ON_COMPLETE_DAY = 'day' => '日',
    FOCUS_ON_COMPLETE_AMOUNT = 'amount' => '金額',
    FOCUS_ON_COMPLETE_TAX_AMOUNT = 'tax_amount' => '消費税額',
    FOCUS_ON_COMPLETE_TAX_TYPE = 'tax_type' => '消費税区分',
    FOCUS_ON_COMPLETE_TAX_RATE = 'tax_rate_percent' => '消費税率',
  }

  # 入力区分
  INPUT_TYPES = {
    INPUT_TYPE_SIMPLE_SLIP_ACCOUNT_ID = 1 => '簡易入力の勘定科目',
    INPUT_TYPE_JOURNAL_ACCOUNT_ID = 2 => '振替伝票の勘定科目',
    INPUT_TYPE_DEBT_ACCOUNT_ID = 3 => '仮負債精算の勘定科目',
  }
  
  # 住宅借入金等特別控除区分
  MORTGAGE_DEDUCTION_TYPES = {
    MORTGAGE_DEDUCTION_TYPE_GENERAL = 1 => '住',
    MORTGAGE_DEDUCTION_TYPE_CERTIFICATION = 2 => '認',
    MORTGAGE_DEDUCTION_TYPE_RENOVATION = 3 => '増',
    MORTGAGE_DEDUCTION_TYPE_DISASTER = 4 => '震',
    MORTGAGE_DEDUCTION_TYPE_GENERAL_SP = 5 => '住（特）',
    MORTGAGE_DEDUCTION_TYPE_CERTIFICATION_SP = 6 => '認（特）',
    MORTGAGE_DEDUCTION_TYPE_RENOVATION_SP = 7 => '増（特）',
    MORTGAGE_DEDUCTION_TYPE_DISASTER_SP = 8 => '震（特）',
  }
  
  # 所有者区分
  OWNER_TYPES = {
    OWNER_TYPE_COMPANY = 1 => '会社',
    OWNER_TYPE_BRANCH = 2 => '部門',
    OWNER_TYPE_EMPLOYEE = 3 => '従業員',
  }

  # 状態区分
  RENT_STATUS_TYPES = {
    RENT_STATUS_TYPE_USE = 1 => '使用中',
    RENT_STATUS_TYPE_STOP = 2 => '停止中',
  }
  
  # 地代家賃区分
  RENT_TYPES = {
    RENT_TYPE_LAND = 1 => '地代',
    RENT_TYPE_HOUSE = 2 => '家賃',
  }

  # 用途区分
  RENT_USAGE_TYPES = {
    RENT_USAGE_TYPE_BUSINESS = 1 => '事業所',
    RENT_USAGE_TYPE_RENT = 2 => '借家',
  }

  # 帳票区分
  REPORT_TYPES = {
    REPORT_TYPE_BS = 1 => '貸借対照表',
    REPORT_TYPE_PL = 2 => '損益計算書',
    REPORT_TYPE_CF = 3 => 'キャッシュフロー計算書',
    REPORT_TYPE_TRADE_ACCOUNT_PAYABLE = 4 => '⑨買掛金の内訳書',
    REPORT_TYPE_RENT = 5 => '⑮地代家賃等の内訳書',
    REPORT_TYPE_INCOME = 'income' => '別表4　所得の金額の計算に関する明細書',
    REPORT_TYPE_SURPLUS_RESERVE_AND_CAPITAL_STOCK = 'profit_and_capital' => '別表5(1)　利益積立金額及び資本金等の計算に関する明細書',
    REPORT_TYPE_TAX_AND_DUES = 7 => '別表5(2)　租税公課の納付状況等に関する明細書',
    REPORT_TYPE_DIVIDEND_RECEIVED = 'dividend_received' => '別表8　受取配当等の益金不算入に関する明細書',
    REPORT_TYPE_SOCIAL_EXPENSE = 8 => '別表15　交際費等の損金算入に関する明細書',
    REPORT_TYPE_WITHHOLDING_SUMMARY = 20 => '給与所得の源泉徴収等の法定調書合計表',
    REPORT_TYPE_WITHHOLDING_DETAILS = 21 => '給与所得の源泉徴収票',
    REPORT_TYPE_WITHHOLDING_CALC = 22 => '給与所得・退職所得等の所得税徴収高計算書',
    REPORT_TYPE_TRADE_ACCOUNT_RECEIVABLE = 23 => '③売掛金（未収入金）の内訳書',
    REPORT_TYPE_INVESTMENT_SECURITIES = 24 => '⑥有価証券の内訳書',
    REPORT_TYPE_SUSPENSE_RECEIPT = 'suspense_receipt' => '⑩仮受金の内訳書、源泉所得税預り金の内訳',
    REPORT_TYPE_CONSUMPTION_TAX_CACL = 'consumption_tax_calc' => '付表2　課税売上割合・控除対象仕入税額等の計算書'
  }

  # 帳票様式
  REPORT_STYLES = {
    REPORT_STYLE_MONTHLY = 1 => '月別',
    REPORT_STYLE_YEARLY = 2 => '年間',
  }

  # 有価証券目的区分
  SECURITIES_TYPES = {
    SECURITIES_TYPE_FOR_TRADING = 1 => '売買目的（1年以内）',
    SECURITIES_TYPE_FOR_INVESTMENT = 2 => '投資目的（1年越え）',
  }

  # 決算区分
  SETTLEMENT_TYPES = {
    SETTLEMENT_TYPE_HALF = 1 => '中間決算',
    SETTLEMENT_TYPE_FULL = 2 => '本決算',
    SETTLEMENT_TYPE_ADJUST = 3 => '決算調整仕訳',
    SETTLEMENT_TYPE_TRANSFER = 4 => '決算振替仕訳',
  }

  # 性別区分
  SEX_TYPES = {
    SEX_TYPE_M = 'M' => '男',
    SEX_TYPE_F = 'F' => '女',
  }

  # 内部伝票区分
  INTERNAL_SLIP_TYPES = {
    SLIP_TYPE_AUTO_TRANSFER_INTERNAL_TRADE = 5 => '内部取引',
    SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_COST = 8 => '費用配賦',
    SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_ASSETS = 9 => '資産配賦'
  }
  
  # 部門間伝票区分
  BRANCH_SLIP_TYPES = {
    SLIP_TYPE_TEMPORARY_DEBT = 10 => '負債清算',
  }
    
  # 外部伝票区分
  EXTERNAL_SLIP_TYPES = {
    SLIP_TYPE_SIMPLIFIED = 0 => '簡易入力',
    SLIP_TYPE_TRANSFER = 1 => '一般振替',
    SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE = 2 => '前払振替',
    SLIP_TYPE_AUTO_TRANSFER_ACCRUED_EXPENSE = 3 => '未払振替',
    SLIP_TYPE_AUTO_TRANSFER_EXPENSE = 4 => '計上日振替',
    SLIP_TYPE_AUTO_TRANSFER_PAYROLL = 6 => '給与',
    SLIP_TYPE_DEPRECIATION = 7 => '減価償却',
    SLIP_TYPE_DEEMED_TAX = 13 => 'みなし消費税',
    SLIP_TYPE_INVESTMENT = 14 => '有価証券'
  }

  # 伝票区分
  SLIP_TYPES = INTERNAL_SLIP_TYPES.merge(BRANCH_SLIP_TYPES).merge(EXTERNAL_SLIP_TYPES)
  
  # 状態区分
  STATUS_TYPES = {
    STATUS_TYPE_ON = true => '有効',
    STATUS_TYPE_OFF = false => '無効',
  }

  # 補助科目区分
  SUB_ACCOUNT_TYPES = {
    SUB_ACCOUNT_TYPE_NORMAL = 1 => '通常',
    SUB_ACCOUNT_TYPE_EMPLOYEE = 2 => '従業員',
    SUB_ACCOUNT_TYPE_CUSTOMER = 3 => '取引先',
    SUB_ACCOUNT_TYPE_SAVING_ACCOUNT = 4 => '普通預金',
    SUB_ACCOUNT_TYPE_RENT = 5 => '地代家賃契約先',
    SUB_ACCOUNT_TYPE_ORDER_ENTRY = 6 => '受注先',
    SUB_ACCOUNT_TYPE_ORDER_PLACEMENT = 7 => '発注先',
    SUB_ACCOUNT_TYPE_BRANCH = 8 => '部門',
    SUB_ACCOUNT_TYPE_SOCIAL_EXPENSE = 9 => '接待交際費',
    SUB_ACCOUNT_TYPE_CORPORATE_TAX = 10 => '法人税',
    SUB_ACCOUNT_TYPE_GENERAL_ACCOUNT = 11 => '一般口座',
    SUB_ACCOUNT_TYPE_INVESTMENT = 12 => '投資先',
  }

  # 消費税取り扱い区分
  TAX_MANAGEMENT_TYPES = {
    TAX_MANAGEMENT_TYPE_EXEMPT = 1 => '非課税',
    TAX_MANAGEMENT_TYPE_DEEMED = 2 => 'みなし消費税',
    TAX_MANAGEMENT_TYPE_INCLUSIVE = 3 => '税込経理方式',
    TAX_MANAGEMENT_TYPE_EXCLUSIVE = 4 => '税抜経理方式',
  }

  # 消費税区分
  TAX_TYPES = {
    TAX_TYPE_NONTAXABLE = TaxJp::TAX_TYPE_NONTAXABLE => TaxJp::TAX_TYPES[TaxJp::TAX_TYPE_NONTAXABLE], # 1
    TAX_TYPE_INCLUSIVE = TaxJp::TAX_TYPE_INCLUSIVE => TaxJp::TAX_TYPES[TaxJp::TAX_TYPE_INCLUSIVE],    # 2
    TAX_TYPE_EXCLUSIVE = TaxJp::TAX_TYPE_EXCLUSIVE => TaxJp::TAX_TYPES[TaxJp::TAX_TYPE_EXCLUSIVE],    # 3
  }

  # 取引区分
  TRADE_TYPES = {
    TRADE_TYPE_EXTERNAL = 1 => '外部取引',
    TRADE_TYPE_INTERNAL = 2 => '内部取引',
  }

  # 勘定科目コード
  ACCOUNT_CODE_ACCRUED_EXPENSE = '3183' # 未払費用
  ACCOUNT_CODE_ACCRUED_EXPENSE_EMPLOYEE = '3184' # 未払費用（従業員）
  ACCOUNT_CODE_ADVANCE_MONEY_FOR_BRANCH = '1831' # 立替金（部門）
  ACCOUNT_CODE_ASSETS = '1000' # 資産の部
  ACCOUNT_CODE_BRANCH_OFFICE = '2999' # 支店勘定
  ACCOUNT_CODE_CAPITAL = '4000' # 純資産の部
  ACCOUNT_CODE_CAPITAL_STOCK = '4311' # 資本金
  ACCOUNT_CODE_CASH = '1111' # 現金
  ACCOUNT_CODE_CONSUMPTION_TAX_PAYABLE = '3191' # 未払消費税
  ACCOUNT_CODE_CORPORATE_TAXES = '8911' # 法人税等
  ACCOUNT_CODE_CORPORATE_TAXES_PAYABLE = '3185' # 未払法人税等
  ACCOUNT_CODE_COST_OF_SALES = '8101' # 売上原価
  ACCOUNT_CODE_CREDIT_BY_OWNER = '2901' # 事業主貸
  ACCOUNT_CODE_CURRENT_ASSETS = '1100' # 流動資産の部
  ACCOUNT_CODE_DEBT = '3000' # 負債の部
  ACCOUNT_CODE_DEBT_TO_OWNER = '4313' # 事業主借
  ACCOUNT_CODE_DEPOSITS_RECEIVED = '3301' # 預り金
  ACCOUNT_CODE_DEPRECIATION = '8531' # 減価償却費
  ACCOUNT_CODE_REVENUE_RESERVE = '4513' # 利益準備金
  ACCOUNT_CODE_EARNED_SURPLUS_CARRIED_FORWARD = '4516' # 繰越利益剰余金
  ACCOUNT_CODE_EXPENSE = '8000' # 費用の部
  ACCOUNT_CODE_EXTRAORDINARY_EXPENSE = '8900' # 特別損失
  ACCOUNT_CODE_EXTRAORDINARY_PROFIT = '6300' # 特別利益
  ACCOUNT_CODE_FIXED_ASSET = '2100' # 固定資産
  ACCOUNT_CODE_HEAD_OFFICE = '4999' # 本店勘定
  ACCOUNT_CODE_NON_OPERATING_PROFIT = '6200' # 営業外収益
  ACCOUNT_CODE_NON_OPERATING_EXPENSE = '8800' # 営業外費用
  ACCOUNT_CODE_ORDINARY_DIPOSIT = '1311' # 普通預金
  ACCOUNT_CODE_PAID_FEE = '8681' # 支払手数料
  ACCOUNT_CODE_PERSONAL_CAPITAL = '4312' # 元入金
  ACCOUNT_CODE_PREPAID_EXPENSE = '1841' # 前払費用
  ACCOUNT_CODE_PROFIT = '6000' # 収益の部
  ACCOUNT_CODE_RECEIVABLE = '1551' # 売掛金
  ACCOUNT_CODE_REVENUE = '4511' # 利益余剰金
  ACCOUNT_CODE_SALE = '6121' # 売上高
  ACCOUNT_CODE_SALES_AND_GENERAL_ADMINISTRATIVE_EXPENSE = '8300' # 販売費および一般管理費
  ACCOUNT_CODE_SMALL_CASH = '1121' # 小口現金
  ACCOUNT_CODE_SUSPENSE_TAX_RECEIVED = '3201' # 借受消費税
  ACCOUNT_CODE_SOCIAL_EXPENSE = '8491' # 接待交際費
  ACCOUNT_CODE_TAX_AND_DUES = '8311' # 租税公課
  ACCOUNT_CODE_TEMP_PAY_TAX = '1891' # 仮払消費税
  ACCOUNT_CODE_TEMPORARY_ASSETS  = '1851' # 仮資産
  ACCOUNT_CODE_TEMPORARY_PAYMENT = '1881' # 仮払金
  ACCOUNT_CODE_TEMPORARY_DEBT = '3501' # 仮負債
  ACCOUNT_CODE_UNPAID_EMPLOYEE = '3171' # 未払金（従業員）
  ACCOUNT_CODE_VARIOUS = '0' # 諸口
  ACCOUNT_CODE_ALLOCATED_COST = '8888' # 配賦費用
  ACCOUNT_CODE_ALLOCATED_TAXES = '8988' # 配賦法人税等
  ACCOUNT_CODE_SHARED_COST = '8889' # 分担費用
  ACCOUNT_CODE_SHARED_TAXES = '8989' # 分担法人税等
  ACCOUNT_CODE_DIRECTOR_SALARY = '8322' # 役員給与
  ACCOUNT_CODE_SALARY = '8326' # 給与手当
  ACCOUNT_CODE_ACCRUED_DIRECTOR_BONUS = '3352' # 未払役員賞与
  ACCOUNT_CODE_LEGAL_WELFARE = '8441' # 法定福利費
  ACCOUNT_CODE_ADVANCE_MONEY = '1821' # 立替金
  ACCOUNT_CODE_COMMISSION_PAID = '8681' # 支払手数料
  ACCOUNT_CODE_RENT = '8551' # 地代家賃
  ACCOUNT_CODE_DIVIDEND_RECEIVED = '4222' # 受取配当金
  ACCOUNT_CODE_DEPOSITS_PAID = '1811' # 預け金
  ACCOUNT_CODE_SECURITIES = '1400' # 有価証券
  ACCOUNT_CODE_TRADING_SECURITIES = '1410' # 売買目的有価証券
  ACCOUNT_CODE_INVESTMENT_SECURITIES = '1420' # 投資有価証券
  
  # 補助科目コード
  SUB_ACCOUNT_CODE_DRINKING = '100' # 飲食等
  SUB_ACCOUNT_CODE_OTHERS = '900' # その他
  SUB_ACCOUNT_CODE_INCOME_TAX = '100' # 源泉所得税
  SUB_ACCOUNT_CODE_HEALTH_INSURANCE = '200' # 健康保険料
  SUB_ACCOUNT_CODE_WELFARE_PENSION = '300' # 厚生年金
  SUB_ACCOUNT_CODE_INHABITANT_TAX = '400' # 住民税
  SUB_ACCOUNT_CODE_EMPLOYMENT_INSURANCE = '500' # 雇用保険料
  SUB_ACCOUNT_CODE_FULLY_OWNED_STOCKS = '100' # 完全子法人株式
  SUB_ACCOUNT_CODE_PARTIALLY_OWNED_STOCKS = '200'# 関係法人株式
  SUB_ACCOUNT_CODE_ETC_STOCKS = '300' # その他株式
  SUB_ACCOUNT_CODE_NON_DOMINANT_STOCKS = '400' # 非支配目的株式
  SUB_ACCOUNT_CODE_CORPORATE_ENTERPRISE_TAX = '100' # 法人事業税

end
