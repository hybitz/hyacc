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

ActiveRecord::Schema.define(version: 20160807155331) do

  create_table "accounts", force: :cascade do |t|
    t.string   "code",                         limit: 255, default: "",    null: false
    t.string   "name",                         limit: 255, default: "",    null: false
    t.integer  "dc_type",                      limit: 4,                   null: false
    t.integer  "account_type",                 limit: 4,                   null: false
    t.integer  "sub_account_type",             limit: 4,   default: 1,     null: false
    t.integer  "tax_type",                     limit: 4,                   null: false
    t.string   "description",                  limit: 255
    t.string   "short_description",            limit: 255
    t.integer  "display_order",                limit: 4
    t.string   "path",                         limit: 255, default: "",    null: false
    t.integer  "trade_type",                   limit: 4,   default: 1,     null: false
    t.boolean  "is_settlement_report_account",             default: true,  null: false
    t.integer  "depreciation_method",          limit: 1
    t.boolean  "is_trade_account_payable",                 default: false, null: false
    t.boolean  "journalizable",                            default: true,  null: false
    t.boolean  "deleted",                                  default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "depreciable",                              default: false, null: false
    t.boolean  "personal_only",                            default: false, null: false
    t.boolean  "company_only",                             default: false, null: false
    t.boolean  "is_revenue_reserve_account",               default: false, null: false
    t.integer  "is_tax_account",               limit: 1,   default: 0,     null: false
    t.integer  "parent_id",                    limit: 4
    t.boolean  "system_required",                          default: false, null: false
    t.boolean  "sub_account_editable",                     default: true,  null: false
  end

  add_index "accounts", ["code"], name: "index_accounts_on_code", unique: true, using: :btree
  add_index "accounts", ["name"], name: "index_accounts_on_name", unique: true, using: :btree

  create_table "assets", force: :cascade do |t|
    t.string   "code",                limit: 8,                           default: "",    null: false
    t.string   "name",                limit: 255,                         default: "",    null: false
    t.integer  "status",              limit: 1,                                           null: false
    t.integer  "account_id",          limit: 4,                                           null: false
    t.integer  "branch_id",           limit: 4,                                           null: false
    t.integer  "sub_account_id",      limit: 4
    t.integer  "durable_years",       limit: 2
    t.integer  "ym",                  limit: 8,                                           null: false
    t.integer  "day",                 limit: 2,                                           null: false
    t.integer  "start_fiscal_year",   limit: 4
    t.integer  "end_fiscal_year",     limit: 4
    t.integer  "amount",              limit: 4,                                           null: false
    t.integer  "depreciation_method", limit: 1
    t.integer  "depreciation_limit",  limit: 4
    t.string   "remarks",             limit: 255
    t.decimal  "business_use_ratio",              precision: 5, scale: 2
    t.integer  "journal_detail_id",   limit: 4
    t.boolean  "deleted",                                                 default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",        limit: 4,                           default: 0,     null: false
  end

  add_index "assets", ["code"], name: "index_assets_on_code", unique: true, using: :btree

  create_table "bank_accounts", force: :cascade do |t|
    t.string   "code",                   limit: 10,  default: "",    null: false
    t.string   "name",                   limit: 255, default: "",    null: false
    t.string   "holder_name",            limit: 255,                 null: false
    t.boolean  "deleted",                            default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bank_id",                limit: 4,                   null: false
    t.integer  "bank_office_id",         limit: 4
    t.integer  "financial_account_type", limit: 4,   default: 0,     null: false
  end

  add_index "bank_accounts", ["name"], name: "index_bank_accounts_on_name", unique: true, using: :btree

  create_table "bank_offices", force: :cascade do |t|
    t.integer  "bank_id",    limit: 4,                   null: false
    t.string   "name",       limit: 255,                 null: false
    t.string   "code",       limit: 3,                   null: false
    t.boolean  "deleted",                default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "disabled",               default: false, null: false
    t.string   "address",    limit: 255
  end

  create_table "banks", force: :cascade do |t|
    t.string   "name",       limit: 255,                 null: false
    t.string   "code",       limit: 4,                   null: false
    t.boolean  "deleted",                default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "disabled",               default: false, null: false
  end

  create_table "branch_employees", force: :cascade do |t|
    t.integer  "branch_id",      limit: 4,                 null: false
    t.integer  "employee_id",    limit: 4,                 null: false
    t.integer  "cost_ratio",     limit: 4, default: 0,     null: false
    t.boolean  "default_branch",           default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "branches", force: :cascade do |t|
    t.string   "code",               limit: 255, default: "",    null: false
    t.string   "name",               limit: 255, default: "",    null: false
    t.integer  "company_id",         limit: 4,                   null: false
    t.integer  "sub_account_id",     limit: 4
    t.boolean  "is_head_office",                 default: false, null: false
    t.integer  "parent_id",          limit: 4
    t.string   "path",               limit: 255, default: "/",   null: false
    t.integer  "cost_ratio",         limit: 4,   default: 100,   null: false
    t.boolean  "deleted",                        default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "business_office_id", limit: 4
  end

  create_table "business_offices", force: :cascade do |t|
    t.integer  "company_id",      limit: 4,                   null: false
    t.string   "name",            limit: 255,                 null: false
    t.string   "prefecture_name", limit: 16,                  null: false
    t.string   "address1",        limit: 255
    t.string   "address2",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",    limit: 4,   default: 0,     null: false
    t.string   "tel",             limit: 13
    t.boolean  "is_head",                     default: false, null: false
    t.string   "prefecture_code", limit: 2,                   null: false
  end

  create_table "business_types", force: :cascade do |t|
    t.string   "name",             limit: 32,                                          null: false
    t.string   "description",      limit: 255
    t.decimal  "deemed_tax_ratio",             precision: 3, scale: 2,                 null: false
    t.boolean  "deleted",                                              default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "business_types", ["name"], name: "index_bisiness_types_on_name", unique: true, using: :btree

  create_table "careers", force: :cascade do |t|
    t.integer  "employee_id",    limit: 4,   null: false
    t.date     "start_from",                 null: false
    t.date     "end_to",                     null: false
    t.integer  "customer_id",    limit: 4,   null: false
    t.string   "customer_name",  limit: 255, null: false
    t.string   "project_name",   limit: 255, null: false
    t.string   "description",    limit: 255
    t.string   "project_size",   limit: 255
    t.string   "role",           limit: 255
    t.string   "process",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "hardware_skill", limit: 255
    t.string   "os_skill",       limit: 255
    t.string   "db_skill",       limit: 255
    t.string   "language_skill", limit: 255
    t.string   "other_skill",    limit: 255
  end

  create_table "companies", force: :cascade do |t|
    t.string   "name",                       limit: 255, default: "",     null: false
    t.integer  "fiscal_year",                limit: 4,                    null: false
    t.integer  "start_month_of_fiscal_year", limit: 4,                    null: false
    t.string   "logo",                       limit: 255, default: ""
    t.date     "founded_date",                                            null: false
    t.integer  "type_of",                    limit: 4,   default: 0,      null: false
    t.string   "admin_email",                limit: 255
    t.boolean  "deleted",                                default: false,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "business_type_id",           limit: 4
    t.integer  "lock_version",               limit: 4,   default: 0,      null: false
    t.string   "payday",                     limit: 255, default: "0,25", null: false
  end

  create_table "customer_names", force: :cascade do |t|
    t.integer  "customer_id", limit: 4,   null: false
    t.string   "name",        limit: 255, null: false
    t.string   "formal_name", limit: 255, null: false
    t.date     "start_date",              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "customer_names", ["customer_id"], name: "index_customer_names_on_customer_id", using: :btree

  create_table "customers", force: :cascade do |t|
    t.string   "code",               limit: 255, default: "",    null: false
    t.boolean  "is_order_entry",                 default: false, null: false
    t.boolean  "is_order_placement",             default: false, null: false
    t.string   "address",            limit: 255, default: ""
    t.boolean  "deleted",                        default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "disabled",                       default: false, null: false
    t.boolean  "is_investment",                  default: false, null: false
  end

  create_table "depreciations", force: :cascade do |t|
    t.integer  "asset_id",        limit: 4,                 null: false
    t.integer  "fiscal_year",     limit: 4,                 null: false
    t.integer  "amount_at_start", limit: 4,                 null: false
    t.integer  "amount_at_end",   limit: 4,                 null: false
    t.boolean  "depreciated",               default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employee_histories", force: :cascade do |t|
    t.integer  "employee_id",      limit: 4,             null: false
    t.integer  "num_of_dependent", limit: 4, default: 0, null: false
    t.date     "start_date",                             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employees", force: :cascade do |t|
    t.integer  "company_id",       limit: 4,                   null: false
    t.string   "first_name",       limit: 255,                 null: false
    t.string   "last_name",        limit: 255,                 null: false
    t.date     "employment_date",                              null: false
    t.string   "zip_code",         limit: 255
    t.string   "address",          limit: 255
    t.string   "sex",              limit: 1,                   null: false
    t.boolean  "deleted",                      default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "birth",                                        null: false
    t.integer  "user_id",          limit: 4
    t.string   "my_number",        limit: 12
    t.boolean  "executive",                    default: false, null: false
    t.integer  "num_of_dependent", limit: 4,   default: 0,     null: false
  end

  create_table "exemptions", force: :cascade do |t|
    t.string   "employee_id",                  limit: 255,             null: false
    t.integer  "yyyy",                         limit: 4,               null: false
    t.integer  "small_scale_mutual_aid",       limit: 4,   default: 0, null: false
    t.integer  "life_insurance_premium",       limit: 4,   default: 0, null: false
    t.integer  "earthquake_insurance_premium", limit: 4,   default: 0, null: false
    t.integer  "special_tax_for_spouse",       limit: 4,   default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "spouse",                       limit: 4,   default: 0, null: false
    t.integer  "dependents",                   limit: 4,   default: 0, null: false
    t.integer  "disabled_persons",             limit: 4,   default: 0, null: false
    t.integer  "basic",                        limit: 4,   default: 0, null: false
  end

  create_table "financial_statements", force: :cascade do |t|
    t.integer  "company_id",    limit: 4,   null: false
    t.integer  "branch_id",     limit: 4,   null: false
    t.integer  "report_type",   limit: 4,   null: false
    t.integer  "ym",            limit: 4,   null: false
    t.integer  "account_id",    limit: 4,   null: false
    t.string   "acccount_name", limit: 255, null: false
    t.integer  "amount",        limit: 4,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fiscal_years", force: :cascade do |t|
    t.integer  "company_id",             limit: 4,                 null: false
    t.integer  "fiscal_year",            limit: 4,                 null: false
    t.integer  "closing_status",         limit: 4, default: 0,     null: false
    t.integer  "tax_management_type",    limit: 4, default: 1,     null: false
    t.boolean  "deleted",                          default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "carry_status",                     default: false, null: false
    t.datetime "carried_at"
    t.integer  "lock_version",           limit: 4, default: 0,     null: false
    t.integer  "consumption_entry_type", limit: 1
  end

  add_index "fiscal_years", ["company_id", "fiscal_year"], name: "index_fiscal_yeras_on_company_id_and_fiscal_year", unique: true, using: :btree

  create_table "housework_details", force: :cascade do |t|
    t.integer  "housework_id",   limit: 4,                         null: false
    t.integer  "account_id",     limit: 4,                         null: false
    t.decimal  "business_ratio",           precision: 5, scale: 2, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sub_account_id", limit: 4
  end

  add_index "housework_details", ["housework_id", "account_id", "sub_account_id"], name: "index_housework_details_as_unique_key", unique: true, using: :btree
  add_index "housework_details", ["housework_id", "account_id"], name: "index_housework_details_on_housework_id_and_account_id", unique: true, using: :btree

  create_table "houseworks", force: :cascade do |t|
    t.integer  "fiscal_year", limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id",  limit: 4, null: false
  end

  create_table "inhabitant_taxes", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "employee_id", limit: 4, null: false
    t.integer  "ym",          limit: 4, null: false
    t.integer  "amount",      limit: 4
  end

  create_table "input_frequencies", force: :cascade do |t|
    t.integer  "user_id",      limit: 4,               null: false
    t.integer  "input_type",   limit: 1,               null: false
    t.string   "input_value",  limit: 30, default: ""
    t.integer  "frequency",    limit: 4,               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "input_value2", limit: 30, default: ""
  end

  add_index "input_frequencies", ["user_id", "input_type", "input_value", "input_value2"], name: "index_input_frequencies_for_unique_key", unique: true, using: :btree

  create_table "investments", force: :cascade do |t|
    t.integer  "shares",            limit: 4, default: 0, null: false
    t.integer  "trading_value",     limit: 4, default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id",       limit: 4
    t.integer  "ym",                limit: 4,             null: false
    t.integer  "day",               limit: 4,             null: false
    t.integer  "bank_account_id",   limit: 4,             null: false
    t.integer  "journal_detail_id", limit: 4
    t.integer  "for_what",          limit: 4,             null: false
    t.integer  "charges",           limit: 4, default: 0, null: false
  end

  create_table "journal_details", force: :cascade do |t|
    t.integer  "journal_header_id",               limit: 4,                                           null: false
    t.integer  "detail_no",                       limit: 4,                                           null: false
    t.integer  "detail_type",                     limit: 4,                           default: 1,     null: false
    t.integer  "dc_type",                         limit: 4,                                           null: false
    t.integer  "account_id",                      limit: 4,                                           null: false
    t.string   "account_name",                    limit: 255,                         default: "",    null: false
    t.integer  "amount",                          limit: 4,                                           null: false
    t.integer  "branch_id",                       limit: 4,                                           null: false
    t.string   "branch_name",                     limit: 255,                                         null: false
    t.integer  "sub_account_id",                  limit: 4
    t.string   "sub_account_name",                limit: 255
    t.integer  "social_expense_number_of_people", limit: 4
    t.string   "note",                            limit: 255
    t.integer  "tax_type",                        limit: 4,                           default: 1,     null: false
    t.integer  "main_detail_id",                  limit: 4
    t.boolean  "is_allocated_cost",                                                   default: false, null: false
    t.boolean  "is_allocated_assets",                                                 default: false, null: false
    t.integer  "housework_detail_id",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "settlement_type",                 limit: 1
    t.decimal  "tax_rate",                                    precision: 4, scale: 3, default: 0.0,   null: false
  end

  add_index "journal_details", ["journal_header_id", "detail_no"], name: "journal_details_journal_header_id_and_detail_no_index", unique: true, using: :btree
  add_index "journal_details", ["main_detail_id"], name: "index_journal_details_main_detail_id", using: :btree

  create_table "journal_headers", force: :cascade do |t|
    t.integer  "ym",                      limit: 4,                   null: false
    t.integer  "day",                     limit: 4,                   null: false
    t.integer  "slip_type",               limit: 4
    t.string   "remarks",                 limit: 255
    t.integer  "amount",                  limit: 4,                   null: false
    t.string   "finder_key",              limit: 255
    t.integer  "transfer_from_id",        limit: 4
    t.integer  "depreciation_id",         limit: 4
    t.integer  "transfer_from_detail_id", limit: 4
    t.integer  "housework_id",            limit: 4
    t.integer  "create_user_id",          limit: 4,                   null: false
    t.integer  "update_user_id",          limit: 4,                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",            limit: 4,   default: 0,     null: false
    t.integer  "fiscal_year_id",          limit: 4
    t.integer  "company_id",              limit: 4,                   null: false
    t.boolean  "deleted",                             default: false, null: false
  end

  add_index "journal_headers", ["company_id", "ym", "day"], name: "index_journal_headers_on_company_id_and_date", using: :btree
  add_index "journal_headers", ["transfer_from_detail_id"], name: "index_journal_headers_transfer_from_detail_id", using: :btree
  add_index "journal_headers", ["ym"], name: "index_journal_headers_on_ym", using: :btree

  create_table "nostalgic_attrs", force: :cascade do |t|
    t.string   "model_type",   limit: 255, null: false
    t.integer  "model_id",     limit: 4,   null: false
    t.string   "name",         limit: 255, null: false
    t.string   "value",        limit: 255
    t.date     "effective_at",             null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "payrolls", force: :cascade do |t|
    t.integer  "ym",                                    limit: 4,                 null: false
    t.integer  "payroll_journal_header_id",             limit: 4
    t.integer  "pay_journal_header_id",                 limit: 4
    t.integer  "days_of_work",                          limit: 4, default: 0
    t.integer  "hours_of_work",                         limit: 4, default: 0
    t.integer  "hours_of_day_off_work",                 limit: 4, default: 0
    t.integer  "hours_of_early_for_work",               limit: 4, default: 0
    t.integer  "hours_of_late_night_work",              limit: 4, default: 0
    t.string   "credit_account_type_of_income_tax",     limit: 1, default: "0",   null: false
    t.string   "credit_account_type_of_insurance",      limit: 1, default: "0",   null: false
    t.string   "credit_account_type_of_pension",        limit: 1, default: "0",   null: false
    t.string   "credit_account_type_of_inhabitant_tax", limit: 1, default: "0",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "employee_id",                           limit: 4,                 null: false
    t.boolean  "is_bonus",                                        default: false, null: false
    t.integer  "commission_journal_header_id",          limit: 4
  end

  add_index "payrolls", ["pay_journal_header_id"], name: "fk_payrolls_pay_journal_header_id", using: :btree
  add_index "payrolls", ["payroll_journal_header_id"], name: "fk_payrolls_payroll_journal_header_id", using: :btree
  add_index "payrolls", ["ym", "employee_id", "is_bonus"], name: "index_payrolls_ym_and_employee_id_and_is_bonus", unique: true, using: :btree

  create_table "receipts", force: :cascade do |t|
    t.integer  "journal_header_id", limit: 4,                   null: false
    t.string   "file",              limit: 255
    t.string   "original_filename", limit: 255
    t.boolean  "deleted",                       default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rents", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.integer  "status",      limit: 4,   null: false
    t.integer  "customer_id", limit: 4,   null: false
    t.integer  "rent_type",   limit: 4,   null: false
    t.integer  "usage_type",  limit: 4,   null: false
    t.string   "address",     limit: 255
    t.integer  "ymd_start",   limit: 4,   null: false
    t.integer  "ymd_end",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "zip_code",    limit: 7
  end

  create_table "sequences", id: false, force: :cascade do |t|
    t.string   "name",       limit: 32,             null: false
    t.string   "section",    limit: 32
    t.integer  "value",      limit: 4,  default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sequences", ["name", "section"], name: "index_sequences_on_name_and_section", unique: true, using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   default: "", null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "simple_slip_settings", force: :cascade do |t|
    t.integer  "user_id",      limit: 4,  null: false
    t.integer  "account_id",   limit: 4,  null: false
    t.string   "shortcut_key", limit: 10, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "simple_slip_templates", force: :cascade do |t|
    t.string   "remarks",           limit: 255, default: "",    null: false
    t.integer  "owner_type",        limit: 4,                   null: false
    t.integer  "owner_id",          limit: 4,                   null: false
    t.string   "description",       limit: 255
    t.string   "keywords",          limit: 255
    t.integer  "account_id",        limit: 4
    t.integer  "branch_id",         limit: 4
    t.integer  "sub_account_id",    limit: 4
    t.integer  "dc_type",           limit: 1
    t.integer  "amount",            limit: 4
    t.integer  "tax_type",          limit: 1
    t.integer  "tax_amount",        limit: 4
    t.string   "focus_on_complete", limit: 255
    t.boolean  "deleted",                       default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "simple_slip_templates", ["remarks"], name: "index_simple_slip_templates_on_remarks", using: :btree

  create_table "sub_accounts", force: :cascade do |t|
    t.string   "code",                                     limit: 255, default: "",    null: false
    t.string   "name",                                     limit: 255, default: "",    null: false
    t.integer  "account_id",                               limit: 4,                   null: false
    t.boolean  "deleted",                                              default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sub_account_type",                         limit: 2,   default: 1,     null: false
    t.boolean  "social_expense_number_of_people_required",             default: false, null: false
  end

  create_table "tax_admin_infos", force: :cascade do |t|
    t.integer  "journal_header_id",  limit: 4,                 null: false
    t.boolean  "should_include_tax",           default: false, null: false
    t.boolean  "checked",                      default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "login_id",                      limit: 255, default: "",    null: false
    t.integer  "company_id",                    limit: 4,   default: 0,     null: false
    t.string   "email",                         limit: 255, default: ""
    t.integer  "slips_per_page",                limit: 4,   default: 20
    t.string   "salt",                          limit: 255, default: "",    null: false
    t.boolean  "deleted",                                   default: false, null: false
    t.string   "google_account",                limit: 255
    t.string   "crypted_google_password",       limit: 255
    t.integer  "account_count_of_frequencies",  limit: 4,   default: 10,    null: false
    t.string   "yahoo_api_app_id",              limit: 255
    t.boolean  "show_details",                              default: true,  null: false
    t.string   "encrypted_password",            limit: 255, default: "",    null: false
    t.string   "reset_password_token",          limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                 limit: 4,   default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",            limit: 255
    t.string   "last_sign_in_ip",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "otp_secret_key",                limit: 255
    t.integer  "second_factor_attempts_count",  limit: 4,   default: 0
    t.boolean  "use_two_factor_authentication",             default: false, null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["login_id"], name: "index_users_on_login_id", unique: true, using: :btree
  add_index "users", ["otp_secret_key"], name: "index_users_on_otp_secret_key", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
