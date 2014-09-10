# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140907060401) do

  create_table "account_controls", force: true do |t|
    t.integer  "account_id",                           null: false
    t.boolean  "system_required",      default: false, null: false
    t.boolean  "sub_account_editable", default: true,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "account_controls", ["account_id"], name: "index_account_controls_on_account_id", unique: true, using: :btree

  create_table "accounts", force: true do |t|
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
    t.datetime "created_on"
    t.datetime "updated_on"
    t.boolean  "depreciable",                            default: false, null: false
    t.boolean  "personal_only",                          default: false, null: false
    t.boolean  "company_only",                           default: false, null: false
    t.boolean  "is_revenue_reserve_account",             default: false, null: false
    t.integer  "is_tax_account",               limit: 1, default: 0,     null: false
    t.integer  "parent_id"
  end

  add_index "accounts", ["code"], name: "index_accounts_on_code", unique: true, using: :btree
  add_index "accounts", ["name"], name: "index_accounts_on_name", unique: true, using: :btree

  create_table "assets", force: true do |t|
    t.string   "code",                limit: 8,                         default: "",    null: false
    t.string   "name",                                                  default: "",    null: false
    t.integer  "status",              limit: 1,                                         null: false
    t.integer  "account_id",                                                            null: false
    t.integer  "branch_id",                                                             null: false
    t.integer  "sub_account_id"
    t.integer  "durable_years",       limit: 2
    t.integer  "ym",                  limit: 8,                                         null: false
    t.integer  "day",                 limit: 2,                                         null: false
    t.integer  "start_fiscal_year"
    t.integer  "end_fiscal_year"
    t.integer  "amount",                                                                null: false
    t.integer  "depreciation_method", limit: 1
    t.integer  "depreciation_limit"
    t.string   "remarks"
    t.decimal  "business_use_ratio",            precision: 5, scale: 2
    t.integer  "journal_detail_id"
    t.boolean  "deleted",                                               default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",                                          default: 0,     null: false
  end

  add_index "assets", ["code"], name: "index_assets_on_code", unique: true, using: :btree

  create_table "bank_accounts", force: true do |t|
    t.string   "code",                   limit: 10, default: "",    null: false
    t.string   "name",                              default: "",    null: false
    t.string   "holder_name",                                       null: false
    t.boolean  "deleted",                           default: false, null: false
    t.datetime "created_on"
    t.datetime "updated_on"
    t.integer  "bank_id",                                           null: false
    t.integer  "bank_office_id"
    t.integer  "financial_account_type",            default: 0,     null: false
  end

  add_index "bank_accounts", ["name"], name: "index_bank_accounts_on_name", unique: true, using: :btree

  create_table "bank_offices", force: true do |t|
    t.integer  "bank_id",              null: false
    t.string   "name",                 null: false
    t.string   "code",       limit: 3, null: false
    t.boolean  "deleted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "banks", force: true do |t|
    t.string   "name",                                 null: false
    t.string   "code",       limit: 4,                 null: false
    t.boolean  "deleted",              default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "branch_employees", force: true do |t|
    t.integer  "branch_id",                      null: false
    t.integer  "employee_id",                    null: false
    t.integer  "cost_ratio",     default: 0,     null: false
    t.boolean  "default_branch", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "branches", force: true do |t|
    t.string   "code",           default: "",    null: false
    t.string   "name",           default: "",    null: false
    t.integer  "company_id",                     null: false
    t.integer  "sub_account_id"
    t.boolean  "is_head_office", default: false, null: false
    t.integer  "parent_id",      default: 0,     null: false
    t.string   "path",           default: "/",   null: false
    t.integer  "cost_ratio",     default: 100,   null: false
    t.boolean  "deleted",        default: false, null: false
    t.datetime "created_on"
    t.datetime "updated_on"
  end

  create_table "branches_employees", id: false, force: true do |t|
    t.integer  "branch_id",                      null: false
    t.integer  "employee_id",                    null: false
    t.integer  "cost_ratio",     default: 0,     null: false
    t.boolean  "default_branch", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "business_offices", force: true do |t|
    t.integer  "company_id",                                 null: false
    t.string   "name",                                       null: false
    t.integer  "prefecture_id",                              null: false
    t.string   "prefecture_name", limit: 16,                 null: false
    t.string   "address1"
    t.string   "address2"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",               default: 0,     null: false
    t.string   "tel",             limit: 13
    t.boolean  "is_head",                    default: false, null: false
  end

  create_table "business_types", force: true do |t|
    t.string   "name",             limit: 32,                                         null: false
    t.string   "description"
    t.decimal  "deemed_tax_ratio",            precision: 3, scale: 2,                 null: false
    t.boolean  "deleted",                                             default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "business_types", ["name"], name: "index_bisiness_types_on_name", unique: true, using: :btree

  create_table "careers", force: true do |t|
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

  create_table "companies", force: true do |t|
    t.string   "name",                                 default: "",    null: false
    t.integer  "fiscal_year",                                          null: false
    t.integer  "start_month_of_fiscal_year",                           null: false
    t.string   "logo",                                 default: ""
    t.date     "founded_date",                                         null: false
    t.integer  "type_of",                    limit: 1, default: 0,     null: false
    t.string   "admin_email"
    t.boolean  "deleted",                              default: false, null: false
    t.datetime "created_on"
    t.datetime "updated_on"
    t.integer  "business_type_id"
    t.integer  "lock_version",                         default: 0,     null: false
  end

  create_table "customer_names", force: true do |t|
    t.integer  "customer_id", null: false
    t.string   "name",        null: false
    t.string   "formal_name", null: false
    t.date     "start_date",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "customer_names", ["customer_id"], name: "index_customer_names_on_customer_id", using: :btree

  create_table "customers", force: true do |t|
    t.string   "code",               default: "",    null: false
    t.boolean  "is_order_entry",     default: false, null: false
    t.boolean  "is_order_placement", default: false, null: false
    t.string   "address",            default: ""
    t.boolean  "deleted",            default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "depreciation_rates", force: true do |t|
    t.integer  "durable_years",     limit: 2,                                         null: false
    t.decimal  "fixed_amount_rate",           precision: 4, scale: 3,                 null: false
    t.decimal  "rate",                        precision: 4, scale: 3,                 null: false
    t.decimal  "revised_rate",                precision: 4, scale: 3,                 null: false
    t.decimal  "guaranteed_rate",             precision: 6, scale: 5,                 null: false
    t.boolean  "deleted",                                             default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "depreciation_rates", ["durable_years"], name: "index_depreciation_rates_on_durable_years", unique: true, using: :btree

  create_table "depreciations", force: true do |t|
    t.integer  "asset_id",                        null: false
    t.integer  "fiscal_year",                     null: false
    t.integer  "amount_at_start",                 null: false
    t.integer  "amount_at_end",                   null: false
    t.boolean  "depreciated",     default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employee_histories", force: true do |t|
    t.integer  "employee_id",                  null: false
    t.integer  "num_of_dependent", default: 0, null: false
    t.date     "start_date",                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employees", force: true do |t|
    t.integer  "company_id",                                   null: false
    t.string   "first_name",                                   null: false
    t.string   "last_name",                                    null: false
    t.date     "employment_date",                              null: false
    t.string   "zip_code"
    t.string   "address"
    t.string   "sex",                limit: 1,                 null: false
    t.boolean  "deleted",                      default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "business_office_id"
  end

  create_table "fiscal_years", force: true do |t|
    t.integer  "company_id",                                       null: false
    t.integer  "fiscal_year",                                      null: false
    t.integer  "closing_status",                   default: 0,     null: false
    t.integer  "tax_management_type",              default: 1,     null: false
    t.boolean  "deleted",                          default: false, null: false
    t.datetime "created_on"
    t.datetime "updated_on"
    t.boolean  "carry_status",                     default: false, null: false
    t.datetime "carried_at"
    t.integer  "lock_version",                     default: 0,     null: false
    t.integer  "consumption_entry_type", limit: 1
  end

  add_index "fiscal_years", ["company_id", "fiscal_year"], name: "index_fiscal_yeras_on_company_id_and_fiscal_year", unique: true, using: :btree

  create_table "housework_details", force: true do |t|
    t.integer  "housework_id",                           null: false
    t.integer  "account_id",                             null: false
    t.decimal  "business_ratio", precision: 5, scale: 2, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sub_account_id"
  end

  add_index "housework_details", ["housework_id", "account_id", "sub_account_id"], name: "index_housework_details_as_unique_key", unique: true, using: :btree
  add_index "housework_details", ["housework_id", "account_id"], name: "index_housework_details_on_housework_id_and_account_id", unique: true, using: :btree

  create_table "houseworks", force: true do |t|
    t.integer  "fiscal_year", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id",  null: false
  end

  create_table "inhabitant_taxes", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "employee_id", null: false
    t.integer  "ym",          null: false
    t.integer  "amount"
  end

  create_table "input_frequencies", force: true do |t|
    t.integer  "user_id",                              null: false
    t.integer  "input_type",   limit: 1,               null: false
    t.string   "input_value",  limit: 30, default: ""
    t.integer  "frequency",                            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "input_value2", limit: 30, default: ""
  end

  add_index "input_frequencies", ["user_id", "input_type", "input_value", "input_value2"], name: "index_input_frequencies_for_unique_key", unique: true, using: :btree

  create_table "journal_details", force: true do |t|
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
    t.datetime "created_on"
    t.datetime "updated_on"
    t.integer  "settlement_type",                 limit: 1
    t.decimal  "tax_rate",                                  precision: 4, scale: 3, default: 0.0,   null: false
  end

  add_index "journal_details", ["journal_header_id", "detail_no"], name: "journal_details_journal_header_id_and_detail_no_index", unique: true, using: :btree
  add_index "journal_details", ["main_detail_id"], name: "index_journal_details_main_detail_id", using: :btree

  create_table "journal_headers", force: true do |t|
    t.integer  "ym",                                      null: false
    t.integer  "day",                                     null: false
    t.integer  "slip_type"
    t.string   "remarks"
    t.integer  "amount",                                  null: false
    t.string   "finder_key"
    t.integer  "transfer_from_id"
    t.string   "receipt_path"
    t.integer  "depreciation_id"
    t.integer  "transfer_from_detail_id"
    t.integer  "housework_id"
    t.integer  "create_user_id",                          null: false
    t.integer  "update_user_id",                          null: false
    t.datetime "created_on"
    t.datetime "updated_on"
    t.integer  "lock_version",            default: 0,     null: false
    t.integer  "fiscal_year_id"
    t.integer  "company_id",                              null: false
    t.boolean  "deleted",                 default: false, null: false
  end

  add_index "journal_headers", ["transfer_from_detail_id"], name: "index_journal_headers_transfer_from_detail_id", using: :btree
  add_index "journal_headers", ["ym"], name: "index_journal_headers_on_ym", using: :btree

  create_table "payrolls", force: true do |t|
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
  end

  add_index "payrolls", ["pay_journal_header_id"], name: "fk_payrolls_pay_journal_header_id", using: :btree
  add_index "payrolls", ["payroll_journal_header_id"], name: "fk_payrolls_payroll_journal_header_id", using: :btree
  add_index "payrolls", ["ym", "employee_id", "is_bonus"], name: "index_payrolls_ym_and_employee_id_and_is_bonus", unique: true, using: :btree

  create_table "rents", force: true do |t|
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

  create_table "sequences", id: false, force: true do |t|
    t.string   "name",       limit: 32,             null: false
    t.string   "section",    limit: 32
    t.integer  "value",                 default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sequences", ["name", "section"], name: "index_sequences_on_name_and_section", unique: true, using: :btree

  create_table "sessions", force: true do |t|
    t.string   "session_id", default: "", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "simple_slip_settings", force: true do |t|
    t.integer  "user_id",                 null: false
    t.integer  "account_id",              null: false
    t.string   "shortcut_key", limit: 10, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "simple_slip_templates", force: true do |t|
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
  end

  add_index "simple_slip_templates", ["remarks"], name: "index_simple_slip_templates_on_remarks", using: :btree

  create_table "sub_accounts", force: true do |t|
    t.string   "code",                                               default: "",    null: false
    t.string   "name",                                               default: "",    null: false
    t.integer  "account_id",                                                         null: false
    t.boolean  "deleted",                                            default: false, null: false
    t.datetime "created_on"
    t.datetime "updated_on"
    t.integer  "sub_account_type",                         limit: 2, default: 1,     null: false
    t.boolean  "social_expense_number_of_people_required",           default: false, null: false
  end

  create_table "tax_admin_infos", force: true do |t|
    t.integer  "journal_header_id",                  null: false
    t.boolean  "should_include_tax", default: false, null: false
    t.boolean  "checked",            default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "login_id",                     default: "",    null: false
    t.integer  "company_id",                   default: 0,     null: false
    t.string   "email",                        default: ""
    t.integer  "slips_per_page",               default: 20
    t.string   "crypted_password",             default: "",    null: false
    t.string   "salt",                         default: "",    null: false
    t.boolean  "deleted",                      default: false, null: false
    t.datetime "created_on"
    t.datetime "updated_on"
    t.string   "google_account"
    t.string   "crypted_google_password"
    t.integer  "employee_id"
    t.integer  "account_count_of_frequencies", default: 10,    null: false
    t.string   "yahoo_api_app_id"
    t.boolean  "show_details",                 default: true,  null: false
  end

  add_index "users", ["login_id"], name: "index_users_on_login_id", unique: true, using: :btree

  create_table "withheld_taxes", force: true do |t|
    t.integer  "apply_start_ym",  default: 999912, null: false
    t.integer  "apply_end_ym",    default: 999912, null: false
    t.integer  "pay_range_above"
    t.integer  "pay_range_under"
    t.integer  "no_dependent"
    t.integer  "one_dependent"
    t.integer  "two_dependent"
    t.integer  "three_dependent"
    t.integer  "four_dependent"
    t.integer  "five_dependent"
    t.integer  "six_dependent"
    t.integer  "seven_dependent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
