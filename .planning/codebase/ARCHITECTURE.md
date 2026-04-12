# Architecture

**Analysis Date:** 2026-04-12

## Pattern Overview

**Overall:** Standard Rails MVC with domain-driven accounting logic

**Key Characteristics:**
- Multi-tenant by company (each company has its own chart of accounts, employees, fiscal years)
- Double-entry bookkeeping with automatic journal generation (depreciation, payroll, tax calculations)
- Hierarchical account chart-of-accounts with sub-accounts and allocation support
- Service layer for complex business logic (payroll notifications, tax calculations)
- Factory pattern for auto-journal generation with strategy pattern for depreciation methods

## Layers

**Presentation Layer (Controllers & Views):**
- Purpose: HTTP request handling and view rendering
- Location: `app/controllers/`, `app/views/`
- Contains: RESTful controllers, view templates (ERB), request/response handling
- Depends on: Models, Helpers, Concerns (authentication, authorization)
- Used by: HTTP clients, browsers

**Application Logic Layer (Controllers):**
- Purpose: Request orchestration, session management, view attribute handling
- Location: `app/controllers/base/hyacc_controller.rb` (base controller for all domain controllers)
- Contains: Common action patterns, ACL table management, view attribute definitions
- Key pattern: `view_attribute()` class method defines screen requirements per controller/action
- Depends on: Models, Finders, Utilities

**Business Logic Layer (Models & Services):**
- Purpose: Core accounting domain logic, validations, state management
- Location: `app/models/`, `app/services/`
- Contains:
  - Domain models (Account, Journal, JournalDetail, Company, Employee, Payroll, etc.)
  - Finder objects (JournalFinder, ReportFinder, EmployeeFinder, etc.) for filtered list queries
  - Factory objects (AutoJournalFactory, PayrollFactory, DepreciationFactory, etc.) for complex object creation
  - Service classes for multi-step operations (payroll notifications, retirement savings)
- Depends on: ApplicationRecord, Constants, Utilities, Validators
- Used by: Controllers, other models

**Utility Layer:**
- Purpose: Shared helper functions, constants, error handling
- Location: `app/utils/`
- Contains:
  - `hyacc_const.rb` - All business domain constants (account types, slip types, approval statuses, etc.)
  - `hyacc_errors.rb` - Exception classes for domain errors
  - `hyacc_util.rb` - General utility functions for accounting (opposite_dc_type, amount calculations, etc.)
  - Domain-specific utilities: `tax_utils.rb`, `asset_util.rb`, `journal_util.rb`, `boolean_utils.rb`
- Used by: All application layers

**Validation Layer:**
- Purpose: Data integrity and business rule enforcement
- Location: `app/models/` (inline validators) and `app/vaildations/` (custom validators)
- Contains: Custom validators for journals, exemptions, accounts, date handling
- Pattern: ActiveModel validators included in models via `validates_with`

**Cross-Cutting Concerns (Mixins):**
- Purpose: Shared behavior across multiple models and controllers
- Location: `app/models/concerns/` and `app/controllers/concerns/`
- Key concerns:
  - `CompanyAware` - Provides company_id context
  - `CurrentCompany` - Helper for controllers to access current user's company
  - `FiscalYearAware` - Fiscal year context for filtering
  - `BankAccountAware` - Bank account context
  - `EmployeeAware` - Employee context
  - `ViewAttributeHandler` - Loads screen metadata
  - `ExceptionHandler` - Centralized error handling
  - `Years` - Fiscal year calculation helpers
  - `YmdInputState` - Year-month-day input state persistence

## Data Flow

**Simple Journal Entry Flow (Create/Update):**

1. User fills form in browser view (`app/views/journals/_form.html.erb`)
2. JournalsController#create receives POST request
3. HyaccController base class provides authentication, authorization via ACL
4. Controller validates Journal and JournalDetails using validators in `app/models/journal_validator.rb`
5. Before save hooks: `update_sum_info` (calculates debit/credit totals), `set_update_user_id`, `compute_has_auto_transfers`
6. Journal and nested JournalDetails are saved to database
7. After save hook: `update_tax_admin_info` updates tax compliance info
8. Response redirected to journal show page

**Auto-Journal Generation Flow (Payroll Example):**

1. PayrollsController receives create/update action for payroll record
2. Controller triggers `PayrollFactory.new(auto_journal_param).make_journals`
3. Factory pattern via `AutoJournalFactory.get_instance(param)` dispatches to PayrollFactory
4. PayrollFactory creates two journals: payroll expense and salary payment
5. Each journal gets auto-generated JournalDetails for debit/credit entries
6. Journals saved with slip_type = SLIP_TYPE_AUTO_TRANSFER_PAYROLL
7. Transfer journals created with reverse entries for accrual accounting
8. Email notifications sent via `PayrollNotificationProcessor`

**Closing/Consolidation Flow:**

1. User initiates fiscal year closing in ClosingController
2. System finds all non-closed journals for the fiscal year
3. Closing transfer journals created:
   - Opening balances transferred from previous year
   - Revenue accounts closed to income summary
   - Expense accounts closed to income summary
   - Capital accounts updated with net income
4. Fiscal year marked with closing status (CLOSING_STATUS_CLOSING or CLOSING_STATUS_CLOSED)
5. Ledger reports show consolidated balances by account code

**Report Generation Flow (Ledger/Financial Statement):**

1. User requests ledger or financial statement report
2. LedgerFinder or ReportFinder created with filter parameters (account, fiscal year, branch)
3. Finder queries Journal table with conditions: fiscal_year, account_id, deleted=false, etc.
4. Joins JournalDetails to calculate balances
5. Results paginated and returned to view for rendering
6. PDF generation via wicked_pdf for printable output

**State Management:**

- Session storage: Current company, current fiscal year, pagination state, search filters
- Finder objects: Hold filter state (account_id, branch_id, fiscal_year, ym, etc.)
- Before action hooks: Load view attributes, check authentication, set pagination defaults
- Database: All persistent state (companies, journals, accounts, employees)

## Key Abstractions

**Account (Chart of Accounts):**
- Purpose: Represents accounting accounts (assets, liabilities, capital, revenue, expense)
- Files: `app/models/account.rb`, `app/models/accounts/sub_accounts_support.rb`
- Pattern: Tree structure using acts_as_tree gem; accounts can have sub-accounts
- Properties: code, name, account_type (asset/debt/capital/profit/expense), dc_type (debit/credit)
- Key methods:
  - `Account.get_journalizable_accounts()` - Get accounts allowed in journal entries
  - `code_and_name` - Display format "1100:Cash"

**Journal (Entry Posting):**
- Purpose: Records double-entry bookkeeping transaction
- Files: `app/models/journal.rb`, `app/models/journal_detail.rb`
- Pattern: Header-detail relationship (1:N) - Journal has many JournalDetails
- Journal types: normal entry, auto-generated (depreciation, payroll, transfer)
- Key attributes: ym (year-month), day, slip_type, company_id
- Transfer journals: Can reference another journal as source for accrual entries
- Relationships: belongs_to depreciation, investment, payroll (optional); has_many transfer_journals

**Company (Tenant):**
- Purpose: Represents business entity (tenant in multi-tenant system)
- Files: `app/models/company.rb`
- Properties: name, founded_date, enterprise_number, logo, fiscal year settings
- Relationships: has_many employees, fiscal_years, journals, accounts (through chart of accounts)
- Key methods:
  - `current_fiscal_year` - Get active fiscal year
  - `bank_account_for_payroll` - Get payroll bank account
  - `payroll_day(ym)` - Calculate payroll date for month

**FiscalYear:**
- Purpose: Delineates accounting periods for reporting and closing
- Files: `app/models/fiscal_year.rb`
- Pattern: Owned by company; multiple per company
- Properties: fiscal_year (integer), start_date, end_date, closing status
- Key methods: Used to scope journals, calculate reporting periods

**Employee (HR):**
- Purpose: Represents person working for company
- Files: `app/models/employee.rb`
- Relationships: belongs_to company, user; has_many payrolls, dependent family members
- Used for: Payroll calculation, tax withholding, social insurance tracking
- Properties: start_date, end_date, title, salary, insurance numbers

**Payroll (HR/Finance):**
- Purpose: Monthly salary and bonus calculation for employee
- Files: `app/models/payroll.rb`
- Relationships: belongs_to employee, company
- Auto-journals: PayrollFactory creates salary expense journal and transfer journal
- Tax impact: Triggers tax withholding calculations, social insurance

**Asset (Fixed Asset):**
- Purpose: Tracks depreciable fixed assets (equipment, vehicles, buildings)
- Files: `app/models/asset.rb`, `app/models/depreciation.rb`
- Relationships: belongs_to account; has_many depreciation records
- Depreciation strategies: Fixed-amount, fixed-rate (declining balance), lump-sum
- Auto-journal: DepreciationFactory generates monthly depreciation expense journals

**Finder Pattern (Query Encapsulation):**
- Purpose: Encapsulate complex filtered queries for lists and reports
- Examples: `JournalFinder`, `ReportFinder`, `EmployeeFinder`, `LedgerFinder`
- Base: `Base::Finder` class with common attributes (company_id, fiscal_year, page, ym, etc.)
- Methods:
  - `setup_from_params(params)` - Initialize from controller params
  - `list(options)` - Execute query with pagination
- Usage: Controllers create finder, call setup, then list to get paginated results

**Factory Pattern (Complex Object Creation):**
- Purpose: Create complex objects with business rule logic
- Examples: `AutoJournalFactory`, `PayrollFactory`, `DepreciationFactory`, `InvestmentFactory`
- Pattern: Factory.get_instance(param) returns appropriate subclass based on type
- Polymorphic: Each factory type generates specific journal structure
- Used in: Auto-journal generation for payroll, depreciation, investments, tax adjustments

## Entry Points

**Web Application (HTTP):**
- Location: `config/routes.rb`, Puma server via `config/puma.rb`
- Entry: Rails router dispatches to controllers
- Startup: `bin/rails server` or production Puma

**Rails Console:**
- Location: `bin/rails console`
- Used for: Data inspection, bulk operations, maintenance tasks

**Rake Tasks:**
- Location: `lib/tasks/`, config via Rakefile
- Examples: db:migrate, db:seed, custom accounting tasks

**Initializers:**
- Location: `config/initializers/`
- Key initializers:
  - `devise.rb` - Authentication configuration (OAuth, password)
  - `wicked_pdf.rb` - PDF generation for reports
  - `session_store.rb` - ActiveRecord session persistence
  - Custom inflections for Japanese terms

## Error Handling

**Strategy:** Exception hierarchy with specific error classes for domain validation failures

**Patterns:**

1. **Model Validators:** Use `validates_with` for complex business rules
   - Example: `JournalValidator` checks debit/credit balance, account validity
   - Example: `ExemptionValidator` validates tax exemption rules

2. **HyaccException:** Custom exception class in `app/utils/hyacc_exception.rb`
   - Used for domain-specific errors (bad account, invalid fiscal year, etc.)
   - Includes error code and message
   - Example: `ERR_OVERRIDE_NEEDED` for unimplemented factory methods

3. **Rails Validations:** Model-level and form validation
   - Example: Journal validates presence of company_id, ym, day, remarks

4. **Controller Error Handling:**
   - File: `app/controllers/base/exception_handler.rb`
   - Handles StrongActions::ForbiddenAction for authorization failures
   - Renders 403 for forbidden, redirects for unauthenticated

5. **Strong Actions ACL:** Access control list defined in `config/acl.yml`
   - Controls which users can perform which controller actions
   - Enforced via `strong_actions` gem in ApplicationController

## Cross-Cutting Concerns

**Logging:** 
- File: `app/utils/hyacc_logger.rb`
- Approach: Custom logger for application events
- Output: Log to files in `log/` directory
- Development: Detailed SQL queries visible in console

**Validation:**
- Pattern: Multi-level validation
  - Model validators: Business rule enforcement
  - Database constraints: NOT NULL, UNIQUE indexes
  - Controller validators: Strong parameters, view attribute metadata
- Critical validators: JournalValidator, ExemptionValidator, AnnualAdjustmentAccountValidator

**Authentication:**
- Provider: Devise with Omniauth (Google OAuth2, local password)
- Session: ActiveRecord session store (`activerecord-session_store` gem)
- Current user: Available in controllers/views via `current_user`
- Devise model: `app/models/user.rb`

**Authorization:**
- Mechanism: StrongActions ACL via `config/acl.yml`
- Scope: By controller/action, optionally by user role
- Pattern: ACL enforced before controller action execution
- Company context: Current user must have employee in current company

**Multi-Tenancy:**
- Scope: By company (Company model)
- Access: Current user's company accessed via `current_company` helper
- Isolation: All journals, employees, accounts scoped to company_id
- Validation: Models include company_id in uniqueness constraints where applicable

---

*Architecture analysis: 2026-04-12*
