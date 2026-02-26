# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_02_26_100000) do
  create_table "accounts", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "code", default: "", null: false
    t.string "name", default: "", null: false
    t.integer "dc_type", null: false
    t.integer "account_type", null: false
    t.integer "sub_account_type", default: 1, null: false
    t.integer "tax_type", null: false
    t.string "description"
    t.string "short_description"
    t.integer "display_order"
    t.string "path", default: "", null: false
    t.integer "trade_type", default: 1, null: false
    t.boolean "is_settlement_report_account", default: false, null: false
    t.integer "depreciation_method", limit: 1
    t.boolean "is_trade_account_payable", default: false, null: false
    t.boolean "journalizable", default: true, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "depreciable", default: false, null: false
    t.boolean "personal_only", default: false, null: false
    t.boolean "company_only", default: false, null: false
    t.integer "is_tax_account", limit: 1, default: 0, null: false
    t.integer "parent_id"
    t.boolean "system_required", default: false, null: false
    t.boolean "sub_account_editable", default: false, null: false
    t.boolean "is_suspense_receipt_account", default: false, null: false
    t.boolean "is_temporary_payment_account", default: false, null: false
    t.index ["code"], name: "index_accounts_on_code", unique: true
    t.index ["name"], name: "index_accounts_on_name", unique: true
  end

  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata", size: :medium
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "assets", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "code", limit: 8, default: "", null: false
    t.string "name", default: "", null: false
    t.integer "status", limit: 1, null: false
    t.integer "account_id", null: false
    t.integer "branch_id", null: false
    t.integer "durable_years", limit: 2
    t.bigint "ym", null: false
    t.integer "day", limit: 2, null: false
    t.integer "start_fiscal_year"
    t.integer "end_fiscal_year"
    t.integer "amount", null: false
    t.integer "depreciation_method", limit: 1
    t.integer "depreciation_limit"
    t.string "remarks"
    t.decimal "business_use_ratio", precision: 5, scale: 2
    t.integer "journal_detail_id", null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "lock_version", default: 0, null: false
    t.index ["code"], name: "index_assets_on_code", unique: true
  end

  create_table "attendances", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "employee_id", null: false
    t.integer "yyyymm"
    t.integer "day"
    t.time "from"
    t.time "to"
    t.string "holiday_type"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "bank_accounts", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "code", limit: 10, default: "", null: false
    t.string "name", default: "", null: false
    t.string "holder_name", null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "bank_id", null: false
    t.integer "bank_office_id"
    t.integer "financial_account_type", default: 0, null: false
    t.boolean "for_payroll", default: false, null: false
    t.integer "company_id", null: false
    t.index ["name"], name: "index_bank_accounts_on_name", unique: true
  end

  create_table "bank_offices", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "bank_id", null: false
    t.string "name", null: false
    t.string "code", limit: 3, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "disabled", default: false, null: false
    t.string "address"
  end

  create_table "banks", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", limit: 4, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "disabled", default: false, null: false
    t.integer "company_id", null: false
    t.integer "lt_30k_same_office"
    t.integer "ge_30k_same_office"
    t.integer "lt_30k_other_office"
    t.integer "ge_30k_other_office"
    t.integer "lt_30k_other_bank"
    t.integer "ge_30k_other_bank"
    t.string "enterprise_number"
  end

  create_table "branch_employees", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "branch_id", null: false
    t.integer "employee_id", null: false
    t.boolean "default_branch", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "deleted", default: false, null: false
  end

  create_table "branches", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "code", default: "", null: false
    t.string "name", null: false
    t.integer "company_id", null: false
    t.integer "sub_account_id"
    t.integer "parent_id"
    t.string "path", default: "/", null: false
    t.integer "cost_ratio", default: 100, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "business_office_id"
    t.string "formal_name", null: false
  end

  create_table "business_offices", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "company_id", null: false
    t.string "name", null: false
    t.string "prefecture_name", limit: 16, null: false
    t.string "address1"
    t.string "address2"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "lock_version", default: 0, null: false
    t.string "tel", limit: 13
    t.string "prefecture_code", limit: 2, null: false
    t.string "zip_code", limit: 8
    t.boolean "deleted", default: false, null: false
    t.integer "responsible_person_id"
    t.string "business_outline"
    t.boolean "disabled", default: false, null: false
  end

  create_table "business_types", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", limit: 32, null: false
    t.string "description"
    t.decimal "deemed_tax_ratio", precision: 3, scale: 2, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["name"], name: "index_bisiness_types_on_name", unique: true
  end

  create_table "careers", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "employee_id", null: false
    t.date "start_from", null: false
    t.date "end_to", null: false
    t.integer "customer_id", null: false
    t.string "customer_name", null: false
    t.string "project_name", null: false
    t.string "description"
    t.string "project_size"
    t.string "role"
    t.string "process"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "hardware_skill"
    t.string "os_skill"
    t.string "db_skill"
    t.string "language_skill"
    t.string "other_skill"
  end

  create_table "companies", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.integer "fiscal_year"
    t.integer "start_month_of_fiscal_year", null: false
    t.string "logo", default: ""
    t.date "founded_date", null: false
    t.integer "type_of", default: 0, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "business_type_id"
    t.integer "lock_version", default: 0, null: false
    t.string "pay_day_definition", default: "0,25", null: false
    t.string "enterprise_number", limit: 13
    t.integer "employment_insurance_type"
    t.string "labor_insurance_number", limit: 14
    t.string "social_insurance_number"
    t.integer "retirement_savings_after"
  end

  create_table "customers", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "code", default: "", null: false
    t.boolean "is_order_entry", default: false, null: false
    t.boolean "is_order_placement", default: false, null: false
    t.string "address", default: ""
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "disabled", default: false, null: false
    t.boolean "is_investment", default: false, null: false
    t.string "formal_name"
    t.string "name"
    t.string "enterprise_number"
    t.string "invoice_issuer_number"
    t.index ["code"], name: "index_customers_on_code", unique: true
  end

  create_table "dependent_family_members", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "exemption_id", null: false
    t.integer "exemption_type", null: false
    t.string "name", null: false
    t.string "kana", null: false
    t.string "my_number"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "family_sub_type"
    t.string "non_resident_code"
    t.boolean "non_resident", default: false, null: false
  end

  create_table "depreciations", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "asset_id", null: false
    t.integer "fiscal_year", null: false
    t.integer "amount_at_start", null: false
    t.integer "amount_at_end", null: false
    t.boolean "depreciated", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "donation_recipients", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "company_id", null: false
    t.string "kind", limit: 3, null: false
    t.string "name", null: false
    t.string "announcement_number"
    t.string "purpose"
    t.string "address"
    t.string "purpose_or_name"
    t.string "trust_name"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "employee_bank_accounts", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "employee_id", null: false
    t.string "code", null: false
    t.integer "bank_id", null: false
    t.integer "bank_office_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "employees", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "company_id", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.date "employment_date", null: false
    t.string "zip_code", limit: 8
    t.string "address"
    t.string "sex", limit: 1, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.date "birth", null: false
    t.integer "user_id"
    t.string "my_number", limit: 12
    t.boolean "executive", default: false, null: false
    t.integer "num_of_dependent", default: 0, null: false
    t.string "position"
    t.date "retirement_date"
    t.string "first_name_kana"
    t.string "last_name_kana"
    t.integer "social_insurance_reference_number"
    t.boolean "disabled", default: false, null: false
  end

  create_table "exemptions", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "employee_id", null: false
    t.integer "yyyy", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "company_id", null: false
    t.integer "num_of_house_loan"
    t.integer "max_mortgage_deduction"
    t.date "date_of_start_living_1"
    t.string "mortgage_deduction_code_1"
    t.integer "year_end_balance_1"
    t.date "date_of_start_living_2"
    t.string "mortgage_deduction_code_2"
    t.integer "year_end_balance_2"
    t.integer "small_scale_mutual_aid"
    t.integer "life_insurance_premium_new"
    t.integer "life_insurance_premium_old"
    t.integer "earthquake_insurance_premium"
    t.integer "social_insurance_selfpay"
    t.integer "special_tax_for_spouse"
    t.integer "dependents"
    t.integer "spouse"
    t.integer "disabled_persons"
    t.integer "basic"
    t.integer "previous_salary"
    t.integer "previous_withholding_tax"
    t.integer "previous_social_insurance"
    t.text "remarks", size: :medium
    t.integer "care_insurance_premium"
    t.integer "private_pension_insurance_new"
    t.integer "private_pension_insurance_old"
    t.integer "fixed_tax_deduction_amount"
    t.integer "special_deduction_for_specified_family"
    t.integer "income_adjustment_deduction_reason"
    t.index ["yyyy", "employee_id"], name: "index_exemptions_on_yyyy_and_employee_id", unique: true
  end

  create_table "financial_statement_headers", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "branch_id", null: false
    t.integer "report_type", null: false
    t.integer "fiscal_year", null: false
    t.integer "max_node_level", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "report_style"
  end

  create_table "financial_statements", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "ym", null: false
    t.integer "account_id", null: false
    t.string "account_name", null: false
    t.integer "amount", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "financial_statement_header_id"
  end

  create_table "fiscal_years", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "fiscal_year", null: false
    t.integer "closing_status", default: 0, null: false
    t.integer "tax_management_type", default: 1, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "lock_version", default: 0, null: false
    t.integer "consumption_entry_type", limit: 1
    t.integer "accepted_amount_of_excess_depreciation", default: 0, null: false
    t.integer "approved_loss_amount_of_business_tax", default: 0, null: false
    t.string "annual_adjustment_account_id"
    t.index ["company_id", "fiscal_year"], name: "index_fiscal_yeras_on_company_id_and_fiscal_year", unique: true
  end

  create_table "inhabitant_taxes", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "employee_id", null: false
    t.integer "ym", null: false
    t.integer "amount"
  end

  create_table "input_frequencies", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "input_type", limit: 1, null: false
    t.string "input_value", limit: 30, default: ""
    t.integer "frequency", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "input_value2", limit: 30, default: ""
    t.index ["user_id", "input_type", "input_value", "input_value2"], name: "index_input_frequencies_for_unique_key", unique: true
  end

  create_table "investments", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "shares", default: 0, null: false
    t.integer "trading_value", default: 0, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "customer_id", null: false
    t.integer "ym", null: false
    t.integer "day", null: false
    t.integer "bank_account_id", null: false
    t.integer "for_what", null: false
    t.integer "charges", default: 0, null: false
    t.integer "gains", default: 0, null: false
    t.integer "buying_or_selling", null: false
  end

  create_table "journal_detail_donation_recipients", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "journal_detail_id", null: false
    t.integer "donation_recipient_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["journal_detail_id"], name: "index_journal_detail_donation_recipients_on_journal_detail_id", unique: true
  end

  create_table "journal_details", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "journal_id", null: false
    t.integer "detail_no", null: false
    t.integer "detail_type", default: 1, null: false
    t.integer "dc_type", null: false
    t.integer "account_id", null: false
    t.string "account_name", default: "", null: false
    t.integer "amount", null: false
    t.integer "branch_id", null: false
    t.string "branch_name", null: false
    t.integer "sub_account_id"
    t.string "sub_account_name"
    t.integer "social_expense_number_of_people"
    t.string "note"
    t.integer "tax_type", default: 1, null: false
    t.integer "main_detail_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "settlement_type", limit: 1
    t.decimal "tax_rate", precision: 4, scale: 3, default: "0.0", null: false
    t.integer "allocation_type"
    t.index ["journal_id", "detail_no"], name: "journal_details_journal_header_id_and_detail_no_index", unique: true
    t.index ["main_detail_id"], name: "index_journal_details_main_detail_id"
  end

  create_table "journals", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "ym", null: false
    t.integer "day", null: false
    t.integer "slip_type", null: false
    t.string "remarks", null: false
    t.integer "amount", null: false
    t.string "finder_key", limit: 1023
    t.integer "transfer_from_id"
    t.integer "depreciation_id"
    t.integer "transfer_from_detail_id"
    t.integer "create_user_id", null: false
    t.integer "update_user_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "lock_version", default: 0, null: false
    t.integer "company_id", null: false
    t.boolean "deleted", default: false, null: false
    t.boolean "auto", default: false, null: false
    t.integer "payroll_id"
    t.string "type"
    t.integer "investment_id"
    t.index ["company_id", "ym", "day"], name: "index_journal_headers_on_company_id_and_date"
    t.index ["investment_id"], name: "index_journals_on_investment_id"
    t.index ["transfer_from_detail_id"], name: "index_journal_headers_transfer_from_detail_id"
    t.index ["transfer_from_id"], name: "index_journals_on_transfer_from_id"
    t.index ["ym"], name: "index_journals_on_ym"
  end

  create_table "nostalgic_attrs", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "model_type", null: false
    t.integer "model_id", null: false
    t.string "name", null: false
    t.string "value"
    t.date "effective_at", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "notifications", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "deleted", default: false, null: false
    t.integer "category", null: false
    t.integer "ym"
    t.integer "employee_id"
    t.index ["employee_id"], name: "index_notifications_on_employee_id"
  end

  create_table "payrolls", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "ym", null: false
    t.integer "days_of_work", default: 0
    t.integer "hours_of_work", default: 0
    t.integer "hours_of_day_off_work", default: 0
    t.integer "hours_of_early_work", default: 0
    t.integer "hours_of_late_night_work", default: 0
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "employee_id", null: false
    t.boolean "is_bonus", default: false, null: false
    t.integer "commuting_allowance", default: 0, null: false
    t.integer "base_salary", default: 0, null: false
    t.integer "annual_adjustment", default: 0, null: false
    t.integer "accrued_liability", default: 0, null: false
    t.integer "health_insurance", default: 0, null: false
    t.integer "welfare_pension", default: 0, null: false
    t.integer "employment_insurance", default: 0, null: false
    t.integer "income_tax", default: 0, null: false
    t.integer "inhabitant_tax", default: 0, null: false
    t.integer "create_user_id", null: false
    t.integer "update_user_id", null: false
    t.date "pay_day", null: false
    t.integer "monthly_standard", default: 0, null: false
    t.integer "housing_allowance", default: 0, null: false
    t.integer "extra_pay", default: 0, null: false
    t.integer "temporary_salary", default: 0, null: false
    t.integer "transfer_fee", default: 0, null: false
    t.integer "qualification_allowance", default: 0, null: false
    t.integer "misc_adjustment", default: 0, null: false
    t.string "misc_adjustment_note"
    t.index ["ym", "employee_id", "is_bonus"], name: "index_payrolls_ym_and_employee_id_and_is_bonus", unique: true
  end

  create_table "qualifications", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "company_id", null: false
    t.string "name", null: false
    t.integer "allowance", default: 0, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "receipts", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "journal_id", null: false
    t.string "file"
    t.string "original_filename"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "rents", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name"
    t.integer "status", null: false
    t.integer "customer_id", null: false
    t.integer "rent_type", null: false
    t.integer "usage_type", null: false
    t.string "address"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "zip_code", limit: 7
    t.date "start_from", null: false
    t.date "end_to"
  end

  create_table "sequences", id: false, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", limit: 32, null: false
    t.string "section", limit: 32
    t.integer "value", default: 0, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["name", "section"], name: "index_sequences_on_name_and_section", unique: true
  end

  create_table "sessions", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "session_id", default: "", null: false
    t.text "data", size: :medium
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "simple_slip_settings", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "account_id", null: false
    t.string "shortcut_key", limit: 10, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "simple_slip_templates", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "remarks", default: "", null: false
    t.integer "owner_type", null: false
    t.integer "owner_id", null: false
    t.string "description"
    t.string "keywords"
    t.integer "account_id"
    t.integer "branch_id"
    t.integer "sub_account_id"
    t.integer "dc_type", limit: 1
    t.integer "amount"
    t.integer "tax_type", limit: 1
    t.integer "tax_amount"
    t.string "focus_on_complete"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.decimal "tax_rate", precision: 4, scale: 3
    t.index ["remarks"], name: "index_simple_slip_templates_on_remarks"
  end

  create_table "skills", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "employee_id", null: false
    t.integer "qualification_id", null: false
    t.date "qualified_on", null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "sub_accounts", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "code", default: "", null: false
    t.string "name", default: "", null: false
    t.integer "account_id", null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "tax_admin_infos", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "journal_id", null: false
    t.boolean "should_include_tax", default: false, null: false
    t.boolean "checked", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "user_notifications", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "notification_id", null: false
    t.boolean "visible", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notification_id"], name: "fk_user_notifications_notifications"
    t.index ["user_id", "notification_id"], name: "index_user_notifications_on_user_id_and_notification_id", unique: true
  end

  create_table "users", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "login_id", default: "", null: false
    t.string "email", default: ""
    t.integer "slips_per_page", default: 20
    t.string "salt", default: "", null: false
    t.boolean "deleted", default: false, null: false
    t.string "google_account"
    t.integer "account_count_of_frequencies", default: 10, null: false
    t.boolean "show_details", default: true, null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "otp_secret_key"
    t.integer "second_factor_attempts_count", default: 0
    t.boolean "use_two_factor_authentication", default: false, null: false
    t.boolean "admin", default: false, null: false
    t.string "direct_otp"
    t.datetime "direct_otp_sent_at", precision: nil
    t.datetime "totp_timestamp", precision: nil
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["login_id"], name: "index_users_on_login_id", unique: true
    t.index ["otp_secret_key"], name: "index_users_on_otp_secret_key", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "notifications", "employees"
  add_foreign_key "user_notifications", "notifications", name: "fk_user_notifications_notifications"
  add_foreign_key "user_notifications", "users", name: "fk_user_notifications_users"
end
