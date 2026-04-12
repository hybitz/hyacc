# Coding Conventions

**Analysis Date:** 2026-04-12

## Naming Patterns

**Files:**
- Model files: `snake_case.rb` (e.g., `journal.rb`, `fiscal_year.rb`)
- Controller files: `snake_case_controller.rb` (e.g., `accounts_controller.rb`)
- Test files: `{entity}_test.rb` or nested modules like `journals_controller/destroy_test.rb`
- Utility files: `snake_case_util.rb` or `{purpose}_utils.rb` (e.g., `hyacc_util.rb`, `tax_utils.rb`)
- Validator files: `{name}_validator.rb` (e.g., `unique_sub_accounts_validator.rb`)

**Functions/Methods:**
- `snake_case` for all methods: `update_sum_info`, `get_journalizable_accounts`, `create_user_name`
- Query methods with prefix: `get_*` (e.g., `get_net_sum`, `get_actual_pay_day_for`) or direct scopes
- Predicate methods with `?` suffix: `has_auto_transfers?`, `debit?`, `is_leaf?`, `external_trade?`
- Methods starting with underscore are private/internal: `_company` (cached instance variables)

**Variables:**
- Instance variables: `@variable_name` (e.g., `@payroll`, `@company`)
- Cached test data: `@_variable_name` (e.g., `@_company`, `@_account`, `@_expense_account`)
- Local variables: `snake_case`
- Constants: `SCREAMING_SNAKE_CASE` (e.g., `ACCOUNT_TYPE_ASSET`, `DC_TYPE_DEBIT`, `TAX_TYPE_NONTAXABLE`)

**Types/Classes:**
- Model classes: `PascalCase` inheriting from `ApplicationRecord` (e.g., `Journal`, `Account`, `Employee`)
- Controller classes: `PascalCase` inheriting from appropriate controller base (e.g., `AccountsController`, `Base::HyaccController`)
- Utility modules: `PascalCase` (e.g., `HyaccConst`, `HyaccErrors`, `HyaccUtil`)
- Test classes: `PascalCase` inheriting from `ActiveSupport::TestCase` or `ActionController::TestCase`
- Namespaced classes use `::` (e.g., `Auto::Journal::PayrollFactory`, `TransferJournal::PrepaidExpenseFactory`)

## Code Style

**Formatting:**
- No formal linter configuration found (.rubocop.yml not present)
- Code follows Rails conventions by default
- Spacing: Standard Rails indentation (2 spaces)

**Linting:**
- No explicit linting tool enforced; code is Rails-idiomatic
- Comments use Japanese extensively alongside English

## Import Organization

**Order:**
1. Standard library requires
2. Rails/gem requires
3. Application module includes

**Examples from codebase:**
```ruby
# Models include these consistently
class Journal < ApplicationRecord
  include HyaccErrors
  include JournalDate
```

**Path Aliases:**
- No custom path aliases observed; uses standard Rails app/* structure
- Tests use relative requires: `require 'test_helper'`

## Error Handling

**Patterns:**
- Constants defined in `app/utils/hyacc_errors.rb` as module `HyaccErrors`
- All models include `HyaccErrors` module for access to error messages
- Error constants are all-caps with `ERR_` prefix: `ERR_ACCOUNT_ALREADY_USED`, `ERR_DB`, `ERR_STALE_OBJECT`
- Validators use `ActiveModel::Validator` and add errors to record: `record.errors.add(:field, I18n.t('errors.messages.key'))`
- Custom exceptions: `HyaccException < RuntimeError` for domain-specific errors
- Validations use Rails validators: `validates_presence_of`, `validates_format_of`, `validates_with CustomValidator`

**Exception handling in tests:**
```ruby
# Tests verify error behavior explicitly
assert_raise(ActiveRecord::RecordInvalid) { asset.save! }
assert_raise(ActiveRecord::RecordNotFound) { Journal.find(jh.id) }
```

## Logging

**Framework:** No explicit logging library; uses Rails default logging

**Patterns:**
- Logging class: `HyaccLogger` in `app/utils/hyacc_logger.rb`
- Test helpers available through `test_helper.rb`
- In tests: Use assertions and explicit checks rather than logging

## Comments

**When to Comment:**
- Japanese comments explain business logic and accounting concepts
- English comments explain technical implementation details
- Inline comments mark TODOs and FIXMEs: `# TODO`, `# FIXME`
- Comments explain non-obvious accounting rules and constraints

**Example from codebase (`app/models/journal.rb`):**
```ruby
validates_format_of :ym, :with => /\A[0-9]{6}\z/ # TODO 月をもっと正確にチェック
```

**JSDoc/TSDoc:**
- Not used; Ruby docs follow Rails conventions
- Method documentation through comments above methods

## Function Design

**Size:** 
- Methods range from 1-40 lines typically
- Complex logic extracted to utility modules or service classes
- Query methods use ActiveRecord scopes where possible

**Parameters:**
- Explicit parameter naming: `def get_fiscal_year(ym)`, `def create_journal(company:, branch:, employee:, amount:)`
- Hash parameters for options: `def company_params(options = {})`
- Keyword arguments used for clarity: `def default_branch(raise_error: true)`

**Return Values:**
- Query methods return arrays or single records: `get_journalizable_accounts` returns array
- Boolean methods use `?` suffix and return true/false
- Methods may return nil for optional associations
- Scope methods chain for composition

## Module Design

**Exports:**
- Modules define constants and methods for inclusion
- Constants (e.g., `ACCOUNT_TYPES`, `AUTO_JOURNAL_TYPES`) are defined in `HyaccConst` module
- Error messages in `HyaccErrors` module
- Utilities in `HyaccUtil`, `TaxUtils`, `AssetUtil` modules

**Barrel Files:**
- No explicit barrel file pattern; each file has single responsibility
- Test support modules: `test/support/*.rb` each define a single module (e.g., `Banks`, `Accounts`, `Companies`)
- Test helpers auto-included via `test_helper.rb` which requires all files in `test/support/`

**Module Inclusion Pattern:**
All models include both business constant and error modules:
```ruby
class Account < ApplicationRecord
  include HyaccConst
  include HyaccErrors
  include Accounts::SubAccountsSupport
```

Controllers inherit from `Base::HyaccController` which includes:
```ruby
class Base::HyaccController < ApplicationController
  include HyaccConst
  include HyaccErrors
  include ViewAttributeHandler
  include ExceptionHandler
  include YmdInputState
  include Years
```

## Internationalization (i18n)

**Usage:**
- Japanese primary language; English available
- Localization files in `config/locales/`: `ja.yml`, `en.yml`, `title.ja.yml`, `hyacc.ja.yml`
- Uses `I18n.t()` method for translations in validators and controllers

**Examples from codebase:**
```ruby
# In validators (app/models/validators/)
record.errors.add(:base, I18n.t('errors.messages.default_branch_required'))
record.errors.add(:family_sub_type, I18n.t('errors.messages.exemption_type_family_required'))

# In controllers
@title ||= I18n.t("title.#{controller_path}")
flash[:notice] = I18n.t "devise.omniauth_callbacks.success", kind: 'Google'
```

**Locale structure:**
- Form helpers: `helpers.submit.create`, `helpers.submit.update`
- Custom messages: `errors.messages.*` (e.g., `non_existing_account`, `income_tax_sub_account_required`)
- Feature-specific: `title.{controller_path}`, `hyacc.{feature}`
- Third-party: Rails i18n, Devise i18n, WillPaginate i18n

---

*Convention analysis: 2026-04-12*
