# Testing Patterns

**Analysis Date:** 2026-04-12

## Test Framework

**Runner:**
- Minitest ~> 5.0 (Rails default)
- Config: No explicit test configuration file; uses Rails defaults
- Also supports Cucumber for integration testing (in Gemfile)

**Assertion Library:**
- Minitest assertions (Rails built-in)
- No external assertion libraries

**Run Commands:**
```bash
rails test                    # Run all tests
rails test:models             # Run model tests only
rails test:controllers        # Run controller tests only
rails test test/models/       # Run specific test directory
rails test test/models/account_test.rb  # Run specific file
```

## Test File Organization

**Location:**
- Models: `test/models/{name}_test.rb` or nested by feature: `test/models/auto/journal/payroll_factory_test.rb`
- Controllers: `test/controllers/{controller_path}/{test_type}_test.rb` (e.g., `test/controllers/accounts_controller_test.rb`)
- Validators: `test/validations/{validator_name}_test.rb` (e.g., `test/validations/unique_sub_accounts_validator_test.rb`)
- Services: `test/services/{service_path}/{service_test}.rb` (e.g., `test/services/payroll_notification/payroll_notification_context_test.rb`)
- Support modules: `test/support/{entity}.rb` (auto-included, not tests but helpers)
- Fixtures: `test/fixtures/{entity}.yml` (CSV-driven via ERB)
- Fixture data: `test/data/{entity}.csv` (actual data source for fixtures)

**Naming:**
- Test file naming: `{entity}_test.rb` or `{entity}/action_test.rb` for grouped tests
- Test method naming: `test_{action}` or `test_{action}_{scenario}` (Japanese used for clarity)
- Example: `test_削除`, `test_支払手数料に消費税が発生する場合は仮払消費税の仕訳明細を作成する`, `test_has_auto_transfers_通常のsaveでもカラムが計算される`

**Structure:**
```
test/
├── controllers/          # Controller tests (173 test files total)
│   ├── accounts_controller_test.rb
│   └── fiscal_years_controller/
│       └── crud_test.rb
├── models/              # Model tests
│   ├── account_test.rb
│   ├── journal_header_test.rb (240 lines)
│   └── auto/journal/payroll_factory_test.rb
├── services/            # Service/utility tests
├── validations/         # Validator tests
├── support/             # Test helper modules (auto-included)
│   ├── accounts.rb
│   ├── companies.rb
│   ├── helper_methods.rb
│   └── ...25 support modules total
├── fixtures/            # YAML-based test data
├── data/                # CSV data files (source for ERB fixtures)
├── utils/               # Utility test helpers
├── helpers/             # Helper tests
├── test_helper.rb       # Main test configuration
└── application_system_test_case.rb
```

## Test Structure

**Suite Organization:**
```ruby
# Basic model test structure from test/models/business_office_test.rb
require 'test_helper'

class BusinessOfficeText < ActiveSupport::TestCase

  def test_branches
    bo = company.business_offices.create!(business_office_params)
    b = company.branches.create!(branch_params.merge(business_office: bo))
    b2 = company.branches.create!(branch_params.merge(parent: b))

    assert_equal 2, bo.branches.count
    assert_includes bo.branches, b
    assert_includes bo.branches, b2
  end

end
```

**Patterns:**
- Setup: Tests create test data inline or use fixtures via `fixtures :all` in parent class
- Teardown: Database cleaning handled by Rails test harness
- Assertion pattern: Direct assertions using Minitest methods (assert_equal, assert_includes, assert_nothing_raised, assert_raise)
- Controller test setup: `setup` method signs in user before tests

**Controller Test Example:**
```ruby
class FiscalYearsController::CrudTest < ActionController::TestCase

  def setup
    sign_in user  # Helper from test_helper.rb
  end

  def test_一覧
    get :index
    assert_response :success
    assert_template :index
    fiscal_years = assigns(:fiscal_years)
    assert_not_nil fiscal_years
  end

end
```

**Integration Test Example (from test_helper.rb):**
```ruby
class ActionDispatch::IntegrationTest

  def sign_in(user)
    post user_session_path, params: {user: {login_id: user.login_id, password: 'testpassword20260217'}}
    assert_response :redirect
    assert_redirected_to root_path
    @_current_user = user
  end

end
```

## Mocking

**Framework:** 
- No explicit mocking library found (minitest/mock available via stdlib)
- Most tests use fixtures and real database objects

**Patterns:**
- Fixtures loaded via ERB that reads from CSV: `test/fixtures/accounts.yml` reads from `test/data/accounts.csv`
- In-test object creation: `Company.create!(company_params)`, `Branch.create!(branch_params)`
- Transaction isolation: Each test runs in database transaction and rolls back

**What to Mock:**
- Not commonly mocked; tests prefer real objects from fixtures/factories
- External services would be mocked but none detected in codebase

**What NOT to Mock:**
- ActiveRecord models (use real instances)
- Validations (test them directly)
- Database operations (tests expect real DB)

## Fixtures and Factories

**Test Data:**
- YAML fixtures with ERB rendering to load from CSV
- Fixture file: `test/fixtures/accounts.yml` (8 lines, uses ERB)
- Source data: `test/data/accounts.csv` (7617 bytes, contains real test data)

**Example fixture structure:**
```erb
<% require 'csv' %>
<% CSV.foreach("test/data/#{File.basename(__FILE__, '.yml')}.csv", headers: true) do |row| %>
<%= row['id'] %>:
<% row.headers.each do |column| %>
  <%= column %>: <%= row[column] %>
<% end %>
<% end %>
```

**Location:**
- Fixtures: `test/fixtures/*.yml` (auto-loaded via `fixtures :all` in ActiveSupport::TestCase)
- CSV data: `test/data/*.csv`
- Test support modules: `test/support/*.rb` (define query helpers for tests)

**Support Module Pattern (from test/support/accounts.rb):**
```ruby
module Accounts
  include HyaccConst

  def account
    @_account ||= Account.not_deleted.first
  end
  
  def deleted_account
    @_deleted_account ||= Account.where(:deleted => true).first
  end

  def expense_account
    if @_expense_account.nil?
      assert @_expense_account = Account.expenses.where(:sub_account_type => SUB_ACCOUNT_TYPE_NORMAL, :journalizable => true, deleted: false).first
    end
    @_expense_account
  end

  def account_params
    {
      code: '9999',
      name: SecureRandom.uuid,
      dc_type: DC_TYPE_DEBIT,
      account_type: ACCOUNT_TYPE_ASSET,
      tax_type: TAX_TYPE_NONTAXABLE,
      is_suspense_receipt_account: false
    }
  end

  def invalid_account_params
    {
      code: '9999',
      name: '',
      dc_type: DC_TYPE_DEBIT,
      account_type: ACCOUNT_TYPE_ASSET,
      tax_type: TAX_TYPE_NONTAXABLE
    }
  end
end
```

**Support Modules auto-included (25 total):**
All modules in `test/support/*.rb` are automatically required and included in `ActiveSupport::TestCase` via `test_helper.rb`:
```ruby
Dir[File.join(File.dirname(__FILE__), 'support', '*.rb')].each do |f|
  require f
  include File.basename(f).split('.').first.camelize.constantize
end
```

## Coverage

**Requirements:** None enforced; simplecov available but not mandatory

**View Coverage:**
```bash
SIMPLECOV=1 rails test    # If enabled, generates coverage report
```

Coverage gem available (`gem 'simplecov', require: false`) but not active by default.

## Test Types

**Unit Tests:**
- Scope: Individual model methods, validators, utilities
- Approach: Create fixtures, call method, assert result
- Location: `test/models/{model}_test.rb`
- Example from `test/models/asset_test.rb`: Tests each validation independently

**Integration Tests:**
- Scope: Controller actions with authentication, database state
- Approach: Sign in user, make HTTP request, verify response and side effects
- Location: `test/controllers/`
- Uses: `assert_response :success`, `assert_template`, `assigns()`, `assert_difference`
- Example from `test/controllers/fiscal_years_controller/crud_test.rb`: Tests create, read, update flows

**Feature/System Tests:**
- Scope: Full browser-like workflows
- Framework: Capybara available but not extensively used
- Location: `test/system/`, `test/integration/` (mostly empty)
- Status: Minimal system test coverage; most testing via controller tests

**Helper Tests:**
- Location: `test/helpers/`
- Scope: View helper methods

## Common Patterns

**Async Testing:**
- AJAX tests use `xhr: true` parameter
- Example from `test/controllers/fiscal_years_controller/crud_test.rb`:
```ruby
post :create, xhr: true, params: {fiscal_year: fiscal_year_params(user: user)}
assert_response :success
```

**Error Testing:**
- Validations tested by setting invalid data and asserting save fails
- Example from `test/models/asset_test.rb`:
```ruby
asset.amount = nil
assert_raise(ActiveRecord::RecordInvalid) { asset.save! }
```

- OR by checking error messages:
```ruby
assert fy.invalid?
assert_includes fy.errors[:annual_adjustment_account_id], I18n.t('errors.messages.non_existing_account')
```

**Database Differences:**
- Track changes: `assert_difference 'Journal.count', -1 do`
- No change expected: `assert_no_difference 'Journal.count' do`

**Test with Real Data:**
```ruby
def test_has_auto_transfers_自動振替がない場合はカラムがfalse
  j = Journal.find(1)  # Load from fixture
  assert j.save!
  assert_equal false, j.reload.read_attribute(:has_auto_transfers)
  assert_not j.has_auto_transfers?
end
```

**Authenticated Tests:**
```ruby
def setup
  sign_in user  # Helper from test_helper.rb / Devise::Test::ControllerHelpers
end

def test_参照
  sign_in user
  get :show, :xhr => true, :params => {:id => account.id}
  assert_response :success
end
```

**File Upload Testing:**
From `test_helper.rb`:
```ruby
def upload_file(filename)
  path = File.join('test', 'upload_files', filename)
  Rack::Test::UploadedFile.new(path, MimeMagic.by_path(path))
end
```

## Test Helper Configuration

**Main file:** `test/test_helper.rb`

**Key setup:**
- Includes `HyaccConst` and `HyaccErrors` modules in all test cases
- Loads all fixtures automatically: `fixtures :all`
- Auto-includes all support modules from `test/support/`
- Adds Devise authentication helpers to ActionController::TestCase
- Defines sign_in method for both controller and integration tests
- Defines current_user and current_company helpers

**Fixture Upload Support:**
- Upload files stored in `test/upload_files/`
- Helper method `upload_file(filename)` available in tests

---

*Testing analysis: 2026-04-12*
