# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170730044018) do

  create_table "accounts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "code",                                   default: "",    null: false
    t.string   "name",                                   default: "",    null: false
    t.integer  "dc_type",                                                null: false
    t.integer  "account_type",                                           null: false
    t.integer  "sub_account_type",                       default: 1,     null: false
    t.integer  "tax_type",                                               null: false
    t.string   "description"
    t.string   "short_description"
    t.integer  "display_order"
    t.string   "path",                                   default: "",    null: false
    t.integer  "trade_type",                             default: 1,     null: false
    t.boolean  "is_settlement_report_account",           default: true,  null: false
    t.integer  "depreciation_method",          limit: 1
    t.boolean  "is_trade_account_payable",               default: false, null: false
    t.boolean  "journalizable",                          default: true,  null: false
    t.boolean  "deleted",                                default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "depreciable",                            default: false, null: false
    t.boolean  "personal_only",                          default: false, null: false
    t.boolean  "company_only",                           default: false, null: false
    t.boolean  "is_revenue_reserve_account",             default: false, null: false
    t.integer  "is_tax_account",               limit: 1, default: 0,     null: false
    t.integer  "parent_id"
    t.boolean  "system_required",                        default: false, null: false
    t.boolean  "sub_account_editable",                   default: true,  null: false
    t.index ["code"], name: "index_accounts_on_code", unique: true, using: :btree
    t.index ["name"], name: "index_accounts_on_name", unique: true, using: :btree
  end

  create_table "assets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "code",                limit: 8,                         default: "",    null: false
    t.string   "name",                                                  default: "",    null: false
    t.integer  "status",              limit: 1,                                         null: false
    t.integer  "account_id",                                                            null: false
    t.integer  "branch_id",                                                             null: false
    t.integer  "sub_account_id"
    t.integer  "durable_years",       limit: 2
    t.bigint   "ym",                                                                    null: false
    t.integer  "day",                 limit: 2,                                         null: false
    t.integer  "start_fiscal_year"
    t.integer  "end_fiscal_year"
    t.integer  "amount",                                                                null: false
    t.integer  "depreciation_method", limit: 1
    t.integer  "depreciation_limit"
    t.string   "remarks"
    t.decimal  "business_use_ratio",            precision: 5, scale: 2
    t.integer  "journal_detail_id",                                                     null: false
    t.boolean  "deleted",                                               default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",                                          default: 0,     null: false
    t.index ["code"], name: "index_assets_on_code", unique: true, using: :btree
  end

  create_table "bank_accounts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "code",                   limit: 10, default: "",    null: false
    t.string   "name",                              default: "",    null: false
    t.string   "holder_name",                                       null: false
    t.boolean  "deleted",                           default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bank_id",                                           null: false
    t.integer  "bank_office_id"
    t.integer  "financial_account_type",            default: 0,     null: false
    t.index ["name"], name: "index_bank_accounts_on_name", unique: true, using: :btree
  end

  create_table "bank_offices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "bank_id",                              null: false
    t.string   "name",                                 null: false
    t.string   "code",       limit: 3,                 null: false
    t.boolean  "deleted",              default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "disabled",             default: false, null: false
    t.string   "address"
  end

  create_table "banks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name",                                 null: false
    t.string   "code",       limit: 4,                 null: false
    t.boolean  "deleted",              default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "disabled",             default: false, null: false
  end

  create_table "branch_employees", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "branch_id",                      null: false
    t.integer  "employee_id",                    null: false
    t.integer  "cost_ratio",     default: 0,     null: false
    t.boolean  "default_branch", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "branches", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "code",               default: "",    null: false
    t.string   "name",               default: "",    null: false
    t.integer  "company_id",                         null: false
    t.integer  "sub_account_id"
    t.integer  "parent_id"
    t.string   "path",               default: "/",   null: false
    t.integer  "cost_ratio",         default: 100,   null: false
    t.boolean  "deleted",            default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "business_office_id"
  end

  create_table "business_offices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "company_id",                             null: false
    t.string   "name",                                   null: false
    t.string   "prefecture_name", limit: 16,             null: false
    t.string   "address1"
    t.string   "address2"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",               default: 0, null: false
    t.string   "tel",             limit: 13
    t.string   "prefecture_code", limit: 2,              null: false
    t.string   "zip_code",        limit: 8
  end

  create_table "business_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name",             limit: 32,                                         null: false
    t.string   "description"
    t.decimal  "deemed_tax_ratio",            precision: 3, scale: 2,                 null: false
    t.boolean  "deleted",                                             default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_bisiness_types_on_name", unique: true, using: :btree
  end

  create_table "careers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "employee_id",    null: false
    t.date     "start_from",     null: false
    t.date     "end_to",         null: false
    t.integer  "customer_id",    null: false
    t.string   "customer_name",  null: false
    t.string   "project_name",   null: false
    t.string   "description"
    t.string   "project_size"
    t.string   "role"
    t.string   "process"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "hardware_skill"
    t.string   "os_skill"
    t.string   "db_skill"
    t.string   "language_skill"
    t.string   "other_skill"
  end

  create_table "companies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name",                                  default: "",     null: false
    t.integer  "fiscal_year",                                            null: false
    t.integer  "start_month_of_fiscal_year",                             null: false
    t.string   "logo",                                  default: ""
    t.date     "founded_date",                                           null: false
    t.integer  "type_of",                               default: 0,      null: false
    t.string   "admin_email"
    t.boolean  "deleted",                               default: false,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "business_type_id"
    t.integer  "lock_version",                          default: 0,      null: false
    t.string   "payday",                                default: "0,25", null: false
    t.string   "enterprise_number",          limit: 13
  end

  create_table "customers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "code",               default: "",    null: false
    t.boolean  "is_order_entry",     default: false, null: false
    t.boolean  "is_order_placement", default: false, null: false
    t.string   "address",            default: ""
    t.boolean  "deleted",            default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "disabled",           default: false, null: false
    t.boolean  "is_investment",      default: false, null: false
    t.string   "formal_name"
    t.string   "name"
    t.index ["code"], name: "index_customers_on_code", unique: true, using: :btree
  end

  create_table "dependent_family_members", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "exemption_id",                  null: false
    t.integer  "exemption_type",                null: false
    t.string   "name",                          null: false
    t.string   "kana",                          null: false
    t.string   "my_number"
    t.boolean  "live_in",        default: true, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "depreciations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "asset_id",                        null: false
    t.integer  "fiscal_year",                     null: false
    t.integer  "amount_at_start",                 null: false
    t.integer  "amount_at_end",                   null: false
    t.boolean  "depreciated",     default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employees", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "company_id",                                  null: false
    t.string   "first_name",                                  null: false
    t.string   "last_name",                                   null: false
    t.date     "employment_date",                             null: false
    t.string   "zip_code",         limit: 8
    t.string   "address"
    t.string   "sex",              limit: 1,                  null: false
    t.boolean  "deleted",                     default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "birth",                                       null: false
    t.integer  "user_id"
    t.string   "my_number",        limit: 12
    t.boolean  "executive",                   default: false, null: false
    t.integer  "num_of_dependent",            default: 0,     null: false
    t.string   "position"
  end

  create_table "exemptions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "employee_id",                  null: false
    t.integer  "yyyy",                         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id",                   null: false
    t.integer  "mortgage_deduction"
    t.integer  "num_of_house_loan"
    t.integer  "max_mortgage_deduction"
    t.date     "date_of_start_living_1"
    t.string   "mortgage_deduction_code_1"
    t.integer  "year_end_balance_1"
    t.date     "date_of_start_living_2"
    t.string   "mortgage_deduction_code_2"
    t.integer  "year_end_balance_2"
    t.integer  "small_scale_mutual_aid"
    t.integer  "life_insurance_premium_new"
    t.integer  "life_insurance_premium_old"
    t.integer  "earthquake_insurance_premium"
    t.integer  "special_tax_for_spouse"
    t.integer  "dependents"
    t.integer  "spouse"
    t.integer  "disabled_persons"
    t.integer  "basic"
  end

  create_table "financial_statement_headers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "company_id",     null: false
    t.integer  "branch_id",      null: false
    t.integer  "report_type",    null: false
    t.integer  "fiscal_year",    null: false
    t.integer  "max_node_level", null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "report_style"
  end

  create_table "financial_statements", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "ym",                            null: false
    t.integer  "account_id",                    null: false
    t.string   "account_name",                  null: false
    t.integer  "amount",                        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "financial_statement_header_id"
  end

  create_table "fiscal_years", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "company_id",                                       null: false
    t.integer  "fiscal_year",                                      null: false
    t.integer  "closing_status",                   default: 0,     null: false
    t.integer  "tax_management_type",              default: 1,     null: false
    t.boolean  "deleted",                          default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "carry_status",                     default: false, null: false
    t.datetime "carried_at"
    t.integer  "lock_version",                     default: 0,     null: false
    t.integer  "consumption_entry_type", limit: 1
    t.index ["company_id", "fiscal_year"], name: "index_fiscal_yeras_on_company_id_and_fiscal_year", unique: true, using: :btree
  end

  create_table "housework_details", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "housework_id",                           null: false
    t.integer  "account_id",                             null: false
    t.decimal  "business_ratio", precision: 5, scale: 2, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sub_account_id"
    t.index ["housework_id", "account_id", "sub_account_id"], name: "index_housework_details_as_unique_key", unique: true, using: :btree
    t.index ["housework_id", "account_id"], name: "index_housework_details_on_housework_id_and_account_id", unique: true, using: :btree
  end

  create_table "houseworks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "fiscal_year", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id",  null: false
  end

  create_table "inhabitant_taxes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "employee_id", null: false
    t.integer  "ym",          null: false
    t.integer  "amount"
  end

  create_table "input_frequencies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "user_id",                              null: false
    t.integer  "input_type",   limit: 1,               null: false
    t.string   "input_value",  limit: 30, default: ""
    t.integer  "frequency",                            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "input_value2", limit: 30, default: ""
    t.index ["user_id", "input_type", "input_value", "input_value2"], name: "index_input_frequencies_for_unique_key", unique: true, using: :btree
  end

  create_table "investments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "shares",            default: 0, null: false
    t.integer  "trading_value",     default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
    t.integer  "ym",                            null: false
    t.integer  "day",                           null: false
    t.integer  "bank_account_id",               null: false
    t.integer  "journal_detail_id"
    t.integer  "for_what",                      null: false
    t.integer  "charges",           default: 0, null: false
  end

  create_table "journal_details", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "journal_header_id",                                                                 null: false
    t.integer  "detail_no",                                                                         null: false
    t.integer  "detail_type",                                                       default: 1,     null: false
    t.integer  "dc_type",                                                                           null: false
    t.integer  "account_id",                                                                        null: false
    t.string   "account_name",                                                      default: "",    null: false
    t.integer  "amount",                                                                            null: false
    t.integer  "branch_id",                                                                         null: false
    t.string   "branch_name",                                                                       null: false
    t.integer  "sub_account_id"
    t.string   "sub_account_name"
    t.integer  "social_expense_number_of_people"
    t.string   "note"
    t.integer  "tax_type",                                                          default: 1,     null: false
    t.integer  "main_detail_id"
    t.boolean  "is_allocated_cost",                                                 default: false, null: false
    t.boolean  "is_allocated_assets",                                               default: false, null: false
    t.integer  "housework_detail_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "settlement_type",                 limit: 1
    t.decimal  "tax_rate",                                  precision: 4, scale: 3, default: "0.0", null: false
    t.index ["journal_header_id", "detail_no"], name: "journal_details_journal_header_id_and_detail_no_index", unique: true, using: :btree
    t.index ["main_detail_id"], name: "index_journal_details_main_detail_id", using: :btree
  end

  create_table "journal_headers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "ym",                                      null: false
    t.integer  "day",                                     null: false
    t.integer  "slip_type"
    t.string   "remarks"
    t.integer  "amount",                                  null: false
    t.string   "finder_key"
    t.integer  "transfer_from_id"
    t.integer  "depreciation_id"
    t.integer  "transfer_from_detail_id"
    t.integer  "housework_id"
    t.integer  "create_user_id",                          null: false
    t.integer  "update_user_id",                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",            default: 0,     null: false
    t.integer  "fiscal_year_id"
    t.integer  "company_id",                              null: false
    t.boolean  "deleted",                 default: false, null: false
    t.index ["company_id", "ym", "day"], name: "index_journal_headers_on_company_id_and_date", using: :btree
    t.index ["transfer_from_detail_id"], name: "index_journal_headers_transfer_from_detail_id", using: :btree
    t.index ["transfer_from_id"], name: "index_journal_headers_on_transfer_from_id", using: :btree
    t.index ["ym"], name: "index_journal_headers_on_ym", using: :btree
  end

  create_table "nostalgic_attrs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "model_type",   null: false
    t.integer  "model_id",     null: false
    t.string   "name",         null: false
    t.string   "value"
    t.date     "effective_at", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payrolls", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "ym",                                                              null: false
    t.integer  "payroll_journal_header_id"
    t.integer  "pay_journal_header_id"
    t.integer  "days_of_work",                                    default: 0
    t.integer  "hours_of_work",                                   default: 0
    t.integer  "hours_of_day_off_work",                           default: 0
    t.integer  "hours_of_early_for_work",                         default: 0
    t.integer  "hours_of_late_night_work",                        default: 0
    t.string   "credit_account_type_of_income_tax",     limit: 1, default: "0",   null: false
    t.string   "credit_account_type_of_insurance",      limit: 1, default: "0",   null: false
    t.string   "credit_account_type_of_pension",        limit: 1, default: "0",   null: false
    t.string   "credit_account_type_of_inhabitant_tax", limit: 1, default: "0",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "employee_id",                                                     null: false
    t.boolean  "is_bonus",                                        default: false, null: false
    t.integer  "commission_journal_header_id"
    t.index ["pay_journal_header_id"], name: "fk_payrolls_pay_journal_header_id", using: :btree
    t.index ["payroll_journal_header_id"], name: "fk_payrolls_payroll_journal_header_id", using: :btree
    t.index ["ym", "employee_id", "is_bonus"], name: "index_payrolls_ym_and_employee_id_and_is_bonus", unique: true, using: :btree
  end

  create_table "receipts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "journal_header_id",                 null: false
    t.string   "file"
    t.string   "original_filename"
    t.boolean  "deleted",           default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rents", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.integer  "status",                null: false
    t.integer  "customer_id",           null: false
    t.integer  "rent_type",             null: false
    t.integer  "usage_type",            null: false
    t.string   "address"
    t.integer  "ymd_start",             null: false
    t.integer  "ymd_end"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "zip_code",    limit: 7
  end

  create_table "sequences", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name",       limit: 32,             null: false
    t.string   "section",    limit: 32
    t.integer  "value",                 default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name", "section"], name: "index_sequences_on_name_and_section", unique: true, using: :btree
  end

  create_table "sessions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "session_id",               default: "", null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id", using: :btree
    t.index ["updated_at"], name: "index_sessions_on_updated_at", using: :btree
  end

  create_table "simple_slip_settings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "user_id",                 null: false
    t.integer  "account_id",              null: false
    t.string   "shortcut_key", limit: 10, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "simple_slip_templates", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "remarks",                     default: "",    null: false
    t.integer  "owner_type",                                  null: false
    t.integer  "owner_id",                                    null: false
    t.string   "description"
    t.string   "keywords"
    t.integer  "account_id"
    t.integer  "branch_id"
    t.integer  "sub_account_id"
    t.integer  "dc_type",           limit: 1
    t.integer  "amount"
    t.integer  "tax_type",          limit: 1
    t.integer  "tax_amount"
    t.string   "focus_on_complete"
    t.boolean  "deleted",                     default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["remarks"], name: "index_simple_slip_templates_on_remarks", using: :btree
  end

  create_table "sub_accounts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "code",                                               default: "",    null: false
    t.string   "name",                                               default: "",    null: false
    t.integer  "account_id",                                                         null: false
    t.boolean  "deleted",                                            default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sub_account_type",                         limit: 2, default: 1,     null: false
    t.boolean  "social_expense_number_of_people_required",           default: false, null: false
  end

  create_table "tax_admin_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "journal_header_id",                  null: false
    t.boolean  "should_include_tax", default: false, null: false
    t.boolean  "checked",            default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "login_id",                      default: "",    null: false
    t.integer  "company_id",                    default: 0,     null: false
    t.string   "email",                         default: ""
    t.integer  "slips_per_page",                default: 20
    t.string   "salt",                          default: "",    null: false
    t.boolean  "deleted",                       default: false, null: false
    t.string   "google_account"
    t.string   "crypted_google_password"
    t.integer  "account_count_of_frequencies",  default: 10,    null: false
    t.string   "yahoo_api_app_id"
    t.boolean  "show_details",                  default: true,  null: false
    t.string   "encrypted_password",            default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                 default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "otp_secret_key"
    t.integer  "second_factor_attempts_count",  default: 0
    t.boolean  "use_two_factor_authentication", default: false, null: false
    t.boolean  "admin",                         default: false, null: false
    t.string   "direct_otp"
    t.datetime "direct_otp_sent_at"
    t.datetime "totp_timestamp"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["login_id"], name: "index_users_on_login_id", unique: true, using: :btree
    t.index ["otp_secret_key"], name: "index_users_on_otp_secret_key", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

end
