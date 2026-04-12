# Codebase Structure

**Analysis Date:** 2026-04-12

## Directory Layout

```
/home/y-matsuda/project/hyacc/
├── app/                          # Rails application code
│   ├── assets/                   # Static assets (images, stylesheets, JavaScript)
│   ├── channels/                 # Action Cable WebSocket channels
│   ├── controllers/              # HTTP request handlers
│   │   ├── base/                 # Base controller classes
│   │   ├── bs/                   # Balance sheet (貸借対照表) controllers
│   │   ├── hr/                   # Human resources & payroll controllers
│   │   ├── mm/                   # Master maintenance (マスタメンテ) controllers
│   │   ├── report/               # Report generation controllers
│   │   ├── users/                # User/authentication controllers
│   │   ├── concerns/             # Controller mixins (authentication, authorization, multi-tenancy)
│   │   └── *.rb                  # Main domain controllers (journals, accounts, etc.)
│   ├── helpers/                  # View helpers
│   │   ├── account_details/      # Account detail rendering helpers
│   │   ├── bs/                   # Balance sheet helpers
│   │   ├── hr/                   # HR report helpers
│   │   ├── mm/                   # Master maintenance helpers
│   │   └── report/               # Report generation helpers
│   ├── jobs/                     # Active Job async tasks
│   ├── mailers/                  # Email generation
│   ├── models/                   # Domain models (ActiveRecord, services, factories)
│   │   ├── auto/                 # Auto journal generation (payroll, depreciation, tax)
│   │   │   ├── journal/          # Journal factories (PayrollFactory, etc.)
│   │   │   └── transfer_journal/ # Transfer journal factories (accrual, allocation, etc.)
│   │   ├── base/                 # Base model classes (ApplicationRecord, Finder)
│   │   ├── concerns/             # Model mixins (company_aware, fiscal_year_aware, etc.)
│   │   ├── deemed_tax/           # Tax calculation logic
│   │   ├── depreciation/         # Fixed asset depreciation
│   │   │   └── strategy/         # Depreciation method strategies
│   │   ├── services/             # Complex business logic (PayrollNotificationProcessor, etc.)
│   │   │   ├── payroll_notification/
│   │   │   └── retirement_savings_notification/
│   │   └── *.rb                  # Domain models (Account, Journal, Company, Employee, etc.)
│   ├── services/                 # Service classes for complex workflows
│   ├── uploaders/                # File upload handlers (CarrierWave)
│   ├── utils/                    # Utility classes and constants
│   │   ├── hyacc_const.rb        # Business constants (account types, slip types, etc.)
│   │   ├── hyacc_errors.rb       # Exception classes
│   │   ├── hyacc_util.rb         # General utility functions
│   │   ├── tax_utils.rb          # Tax calculation utilities
│   │   ├── asset_util.rb         # Fixed asset utilities
│   │   └── *.rb                  # Domain-specific utilities
│   ├── validations/              # Custom validators (NB: directory named "vaildations" in code)
│   └── views/                    # ERB templates
│       ├── application/          # Application layout
│       ├── bs/                   # Balance sheet views
│       ├── common/               # Shared partials
│       ├── devise/               # Authentication views
│       ├── financial_*/          # Financial statement views
│       ├── hr/                   # HR report views
│       ├── journals/             # Journal entry form and list
│       ├── mm/                   # Master maintenance views
│       ├── report/               # Report generation views
│       └── */                    # Domain-specific views
├── bin/                          # Rails executable scripts
│   ├── rails                     # Rails CLI entry point
│   ├── rake                      # Rake task runner
│   └── setup                     # Initial setup script
├── config/                       # Configuration files
│   ├── environments/             # Environment-specific config (development, test, production)
│   ├── first_boot/               # First-time setup configuration
│   ├── initializers/             # App initialization (Devise, PDF, session store)
│   ├── kustomize/                # Kubernetes configuration
│   ├── locales/                  # i18n translations (Japanese)
│   ├── routes/                   # Modular route definitions
│   ├── acl.yml                   # Access control list (StrongActions authorization)
│   ├── aws.yml                   # AWS S3 configuration
│   ├── cable.yml                 # Action Cable configuration
│   ├── database.yml              # Database connection config
│   ├── puma.rb                   # Puma server configuration
│   ├── routes.rb                 # Main route file
│   └── storage.yml               # Active Storage configuration
├── db/                           # Database
│   ├── migrate/                  # Migration files
│   ├── schema.rb                 # Current database schema
│   └── seeds.rb                  # Initial seed data
├── features/                     # Cucumber BDD tests
│   ├── 01.簡易伝票/              # Simple slip feature tests (Japanese)
│   ├── 02.振替伝票/              # Transfer slip feature tests
│   ├── step_definitions/         # Cucumber step implementations
│   └── support/                  # Cucumber support utilities
├── lib/                          # Library code
│   ├── assets/                   # Asset compilation utilities
│   └── tasks/                    # Rake task definitions
├── log/                          # Log files (development.log, test.log)
├── public/                       # Static public assets (error pages, favicon)
├── storage/                      # Local file storage for uploads
├── test/                         # Unit and integration tests (Minitest)
│   ├── controllers/              # Controller tests
│   ├── data/                     # Test data fixtures
│   ├── fixtures/                 # Fixture definitions (YAML)
│   ├── helpers/                  # Helper tests
│   ├── models/                   # Model tests
│   ├── services/                 # Service tests
│   ├── support/                  # Test support utilities
│   ├── system/                   # System/integration tests (Capybara)
│   ├── validations/              # Validator tests
│   ├── test_helper.rb            # Test configuration
│   └── application_system_test_case.rb
├── user_stories/                 # Alternative BDD tests (older structure)
├── vendor/                       # Third-party dependencies
├── Gemfile                       # Ruby gem dependencies
├── Gemfile.lock                  # Locked gem versions
├── config.ru                     # Rack app entry point
├── docker-compose.yml            # Docker Compose configuration
├── Dockerfile.*                  # Docker image definitions
├── Jenkinsfile                   # CI/CD pipeline
└── README.md                     # Project documentation
```

## Directory Purposes

**app/controllers/base/:**
- Purpose: Base controller classes inherited by domain controllers
- Key files:
  - `hyacc_controller.rb` - Main base class with view attribute handling, ACL, exception handling
  - `basic_master_controller.rb` - Base for master maintenance CRUD controllers
  - `exception_handler.rb` - Centralized error handling
  - `view_attribute_handler.rb` - Loads screen metadata from view_attribute definitions
  - `first_boot.rb` - Initial setup/onboarding controller

**app/controllers/mm/:**
- Purpose: Master Maintenance controllers for configuration and setup
- Contains: Company, Employee, Account, Bank, Branch, Customer, etc.
- Pattern: Standard CRUD operations via REST
- Key files: `companies_controller.rb`, `employees_controller.rb`, `accounts_controller.rb`, `bank_accounts_controller.rb`

**app/controllers/report/:**
- Purpose: Report generation and data export
- Contains: Ledgers, financial statements, tax reports, payroll reports
- Pattern: Index-only controllers that accept filter params and render PDF/HTML
- Key files: `ledgers_controller.rb`, `financial_statements_controller.rb`, `consumption_tax_statements_controller.rb`

**app/models/auto/:**
- Purpose: Automatic journal entry generation for complex accounting transactions
- Subdirectory `journal/`: Factories for standalone journals (payroll, depreciation, investments)
- Subdirectory `transfer_journal/`: Factories for transfer journals (accruals, allocations, expense distribution)
- Pattern: Factory method pattern with polymorphic dispatch via type
- Key files: `auto_journal_factory.rb` (factory registry), individual `*_factory.rb` classes

**app/models/concerns/:**
- Purpose: Shared behavior mixins for models
- Pattern: Rails ActiveSupport::Concern modules included into models
- Key concerns:
  - `company_aware.rb` - Adds company association
  - `fiscal_year_aware.rb` - Fiscal year context methods
  - `bank_account_aware.rb` - Bank account context
  - `employee_aware.rb` - Employee context
  - `account_aware.rb` - Account lookup methods
  - `devise_aware.rb` - User authentication helpers

**app/models/auto/:**
- Subdirectory structure for polymorphic factory pattern
- Registry: `AUTO_JOURNAL_TYPES` hash in `hyacc_const.rb` maps type → factory class name

**app/utils/:**
- Purpose: Shared utilities and constants used throughout application
- Key files:
  - `hyacc_const.rb` - ALL business domain constants (900+ lines)
  - `hyacc_errors.rb` - Custom exception classes
  - `hyacc_util.rb` - General utility methods (opposite_dc_type, calculations, etc.)
  - `tax_utils.rb` - Tax calculation helpers
  - `asset_util.rb` - Asset depreciation calculations
  - `journal_util.rb` - Journal entry utilities
  - `hyacc_logger.rb` - Custom logger
  - `hyacc_view_helper.rb` - View-specific utilities

**app/services/:**
- Purpose: Multi-step business logic that doesn't fit single models
- Examples:
  - `payroll_notification/` - Handles payroll-related notifications and state changes
  - `retirement_savings_notification/` - Tracks retirement savings notifications
- Pattern: Service classes with `process` or execute methods, often with context objects

**config/:**
- Purpose: Application configuration and initialization
- Key files:
  - `acl.yml` - Authorization rules (StrongActions) by controller/action
  - `routes.rb` - URL routing (modularized via `routes/` subdirectory)
  - `aws.yml` - AWS S3 credentials and config for file uploads
  - `puma.rb` - Puma server settings (workers, threads, etc.)
  - `environments/production.rb` - Production-specific settings

**db/migrate/:**
- Purpose: Database schema migrations
- Pattern: Rails migration files with timestamps (YYYYMMDDHHMMSS_migration_name.rb)
- Current schema version: 2026_04_08_120000

**test/:**
- Purpose: Unit and integration tests using Minitest framework
- Structure mirrors `app/` (test/models/, test/controllers/, test/helpers/)
- Subdirectory `system/` contains Capybara-based system tests
- Test data in `fixtures/` (YAML format) and `data/` directory

**features/:**
- Purpose: Behavior-driven development tests using Cucumber
- Format: Gherkin language feature files (Japanese)
- Organization: By functional area (01.簡易伝票, 02.振替伝票, etc.)
- Step implementations: `step_definitions/` directory

## Key File Locations

**Entry Points:**
- `config.ru` - Rack application entry point
- `bin/rails` - Rails CLI
- `app/views/layouts/application.html.erb` - Main layout template
- `config/routes.rb` - URL routing definitions

**Configuration:**
- `config/application.rb` - Rails app configuration
- `config/acl.yml` - Authorization rules (action → allowed roles)
- `config/aws.yml` - AWS S3 configuration
- `Gemfile` - Gem dependencies (Rails 8.1, Devise, Carrierwave, etc.)

**Core Logic:**
- `app/controllers/application_controller.rb` - Base for all controllers
- `app/controllers/base/hyacc_controller.rb` - Domain-specific base controller
- `app/models/application_record.rb` - Base for all ActiveRecord models
- `app/models/company.rb` - Multi-tenancy root model
- `app/models/journal.rb` - Core accounting transaction model
- `app/models/account.rb` - Chart of accounts (tree structure)
- `app/models/user.rb` - User/authentication model (via Devise)

**Testing:**
- `test/test_helper.rb` - Minitest configuration
- `test/application_system_test_case.rb` - Capybara system test base
- `features/step_definitions/` - Cucumber step implementations

## Naming Conventions

**Files:**
- Controllers: `plural_name_controller.rb` (e.g., `journals_controller.rb`, `accounts_controller.rb`)
- Models: `singular_name.rb` (e.g., `journal.rb`, `account.rb`)
- Views: Action name as file (e.g., `show.html.erb`, `_form.html.erb` for partials)
- Migrations: `YYYYMMDDHHMMSS_description.rb` (e.g., `20260101000000_create_journals.rb`)
- Tests: `test_plural_name.rb` or `plural_name_test.rb` (e.g., `journal_test.rb`)

**Directories:**
- Controllers by domain: `app/controllers/mm/`, `app/controllers/hr/`, `app/controllers/report/`
- Models by domain: `app/models/auto/`, `app/models/depreciation/`, `app/models/deemed_tax/`
- Tests mirror app structure: `test/models/`, `test/controllers/`, `test/helpers/`

**Classes & Methods:**
- Classes: PascalCase (e.g., `JournalFinder`, `PayrollFactory`, `AutoJournalFactory`)
- Methods: snake_case (e.g., `make_journals`, `find_closing_journals`, `get_journalizable_accounts`)
- Constants: UPPER_SNAKE_CASE (e.g., `ACCOUNT_TYPE_ASSET`, `SLIP_TYPE_NORMAL`, `CLOSING_STATUS_OPEN`)
- Private methods: `private` keyword, snake_case (e.g., `make_conditions`, `reverse_detail`)

**Variables & Attributes:**
- Instance variables: @snake_case (e.g., `@company`, `@journal`, `@finder`)
- Local variables: snake_case (e.g., `journal_count`, `conditions`)
- Attributes: snake_case (e.g., `account_id`, `company_id`, `slip_type`)

**Module & Concern Names:**
- Concerns: PascalCase descriptive (e.g., `CompanyAware`, `FiscalYearAware`, `CurrentCompany`, `ViewAttributeHandler`)
- Modules: PascalCase, often nested (e.g., `Auto::Journal`, `Depreciation::Strategy`)

## Where to Add New Code

**New Feature (Journal Entry Type):**
- Primary code: `app/models/journal.rb` and `app/models/journal_detail.rb`
- Auto-journal factory: Create `app/models/auto/journal/new_type_factory.rb` extending `Auto::AutoJournalFactory`
- Register type: Add entry to `AUTO_JOURNAL_TYPES` hash in `app/utils/hyacc_const.rb`
- Controller: Create/modify action in `JournalsController` or relevant domain controller
- Views: Add form in `app/views/journals/` or domain-specific folder
- Tests: Add model tests in `test/models/` and controller tests in `test/controllers/`

**New Master Data Entity (e.g., Vendor, Product):**
- Model: Create `app/models/vendor.rb` (new domain model)
- Migration: Create `db/migrate/YYYYMMDDHHMMSS_create_vendors.rb` with schema
- Controller: Create `app/controllers/mm/vendors_controller.rb` inheriting from `Base::BasicMasterController`
- Views: Add CRUD views in `app/views/mm/vendors/`
- Routes: Add `resources :vendors` to `config/routes.rb`
- ACL: Add vendor actions to `config/acl.yml` if authorization needed
- Tests: Create `test/models/vendor_test.rb` and `test/controllers/mm/vendors_controller_test.rb`

**New Finder/Search Feature:**
- Finder class: Create `app/models/vendor_finder.rb` extending `Base::Finder`
- Setup: Add `setup_from_params(params)` method for filter handling
- Query: Implement `list(options)` method returning paginated results
- Controller: Use finder in controller action: `@finder = VendorFinder.new(current_user); @finder.setup_from_params(params); @vendors = @finder.list`
- Tests: Create `test/models/vendor_finder_test.rb`

**New Report:**
- Controller: Create `app/controllers/report/vendor_reports_controller.rb`
- Finder: Use existing or create finder for filtered query
- View: Create view in `app/views/report/vendor_reports/` (index.html.erb, _detail.html.erb, etc.)
- PDF: Add PDF partial and configure wicked_pdf in controller if needed
- Routes: Add route with format handling: `resources :vendor_reports, only: :index`

**New Utility/Helper Function:**
- General utility: Add method to `app/utils/hyacc_util.rb`
- Domain-specific: Create new file `app/utils/domain_util.rb` (e.g., `tax_utils.rb`)
- Constants: Add to `app/utils/hyacc_const.rb` if used across application
- View helper: Add to relevant helper in `app/helpers/` (e.g., `app/helpers/report/vendor_reports_helper.rb`)

**New Validation Rule:**
- Model validation: Add `validates` or `validates_with` to model (e.g., `app/models/vendor.rb`)
- Custom validator: Create `app/models/vendor_validator.rb` extending `ActiveModel::Validator`
- Register: Include in model via `validates_with VendorValidator`
- Form validator: Add strong parameters in controller action

**New Background Job:**
- Job class: Create `app/jobs/vendor_import_job.rb` extending `ApplicationJob`
- Enqueue: Call `VendorImportJob.perform_later(payload)` from controller or model callback
- Tests: Create `test/jobs/vendor_import_job_test.rb`

**New Service Class (Multi-step Operation):**
- Service: Create `app/services/vendor_sync/sync_processor.rb` with `process(context)` method
- Context: If complex, create `app/services/vendor_sync/sync_context.rb` to hold state
- Enqueue: Call from controller via `VendorSync::SyncProcessor.new.process(context)`
- Tests: Create `test/services/vendor_sync/sync_processor_test.rb`

## Special Directories

**app/channels/:**
- Purpose: Action Cable WebSocket handlers for real-time updates
- Generated: Not present in current state but configured
- Committed: Yes

**public/:**
- Purpose: Static error pages (403, 404, 500) and favicons
- Generated: No (static files)
- Committed: Yes

**storage/:**
- Purpose: Local file storage for uploads (dev/test environment)
- Generated: Yes (created at runtime)
- Committed: No (in .gitignore)

**tmp/:**
- Purpose: Temporary files (cache, miniprofiler, uploaded files)
- Generated: Yes (at runtime)
- Committed: No (in .gitignore)
- Subdirectory `tmp/user_stories/` contains Cucumber report outputs

**vendor/assets/:**
- Purpose: Third-party JavaScript and CSS assets
- Generated: No (checked in)
- Committed: Yes

**log/:**
- Purpose: Application log files
- Generated: Yes (development.log, test.log)
- Committed: No (in .gitignore)

---

*Structure analysis: 2026-04-12*
