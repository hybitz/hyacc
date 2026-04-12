# Codebase Concerns

**Analysis Date:** 2026-04-12

## Tech Debt

**Unsafe Dynamic Code Evaluation:**
- Issue: Use of `eval()` to instantiate classes and handle parameters
- Files: `app/controllers/base/basic_master_controller.rb` (lines 40, 71), `app/models/auto/auto_journal_factory.rb` (line 9)
- Impact: Security vulnerability - arbitrary code execution risk, difficult to trace dependencies, breaks static analysis
- Fix approach: Replace with `constantize` pattern or explicit factory class mapping; implement strong parameters validation

**Month Validation with Regex:**
- Issue: Month format validation is incomplete and imprecise
- Files: `app/models/journal.rb` (line 21)
- Impact: Could accept invalid month values (e.g., "202213" for month 13)
- Fix approach: Add explicit month range check (01-12) in addition to regex; implement custom validator

**HTML Safety Calls (.html_safe):**
- Issue: Multiple uses of `.html_safe` on user-generated or dynamic content
- Files: `app/controllers/base/exception_handler.rb`, `app/helpers/mm/accounts_helper.rb`, `app/helpers/mm/branches_helper.rb`, `app/helpers/notification_helper.rb`, `app/helpers/report_helper.rb`, `app/helpers/application_helper.rb`
- Impact: XSS vulnerability risk if content is user-controlled; Rails auto-escaping bypassed
- Fix approach: Use `safe_join` for arrays, ensure content is already sanitized, use explicit HTML encoding where appropriate

**Conditional Fallback Logic in Model:**
- Issue: `Journal.has_auto_transfers?` contains TODO noting need for fallback removal after backfill
- Files: `app/models/journal.rb` (lines 78-83)
- Impact: Temporary logic cluttering model; performance overhead checking two conditions
- Fix approach: Complete backfill verification, remove fallback branch, rely solely on `has_auto_transfers` column

## Known Issues

**Raw SQL Queries with find_by_sql:**
- Problem: Heavy reliance on raw SQL in `VMonthlyLedger` and related models
- Files: `app/models/v_monthly_ledger.rb`, `app/jobs/closing_account_job.rb`
- Trigger: Monthly ledger calculations, account closing processes
- Impact: Difficult to maintain, vulnerable to SQL injection if parameters not properly sanitized, no IDE support for SQL
- Workaround: Currently using parameterized queries, but ActiveRecord scope-based approach would be safer

**Looping Database Queries (N+1 Pattern):**
- Problem: Multiple nested loops with database queries in PayrollLogic
- Files: `app/models/payroll_info/payroll_logic.rb` (lines 16-20, 38-44)
- Trigger: Getting base salary calculations, payroll journal details
- Impact: Performance degradation with large employee/payroll datasets; excessive database round trips
- Workaround: Code functions correctly but inefficiently; caching salary data would help

## Security Considerations

**Authentication Coverage Gaps:**
- Risk: Only Devise authentication configured; no authorization framework (pundit/cancancan) detected
- Files: `app/controllers/application_controller.rb`, sparse `before_action` checks in controllers
- Current mitigation: `StrongActions::ForbiddenAction` rescue handler; some controller-level checks
- Recommendations: Implement authorization layer (pundit or policy-based), add comprehensive authorization tests, audit multi-company access controls

**OAuth Integration without Explicit Validation:**
- Risk: OmniAuth integration (Google OAuth2) without detailed verification of scope/permission constraints
- Files: `Gemfile` (omniauth-google-oauth2)
- Current mitigation: Device integration handles basic auth flow
- Recommendations: Review OAuth token validation, implement rate limiting for auth endpoints, audit scope permissions

**First Boot Check Logic:**
- Risk: `check_first_boot` uses simple count checks; vulnerable if race conditions occur during initial setup
- Files: `app/controllers/application_controller.rb` (lines 21-24), `app/controllers/concerns/first_boot.rb`
- Current mitigation: Check skipped for first_boot controller
- Recommendations: Add database-level flag or atomic setup lock to prevent concurrent initialization issues

**File Upload Handling:**
- Risk: CSV file uploads in `BasicMasterController.upload` with limited validation
- Files: `app/controllers/base/basic_master_controller.rb` (lines 86-100)
- Current mitigation: Basic file type handling via Carrierwave
- Recommendations: Add strict file size limits, scan for malicious content, validate CSV structure before parsing

## Performance Bottlenecks

**Large Constant Module:**
- Problem: `HyaccConst` module contains 485 lines of constant definitions
- Files: `app/utils/hyacc_const.rb`
- Cause: All constants defined inline; loaded on every class that includes HyaccConst
- Improvement path: Split into logical concern modules (AccountConst, TaxConst, etc.), lazy-load if needed

**Complex Report Logic Files:**
- Problem: Large monolithic classes handling report generation logic
- Files: `app/models/reports/appendix_15_logic.rb` (240 lines), `app/models/reports/appendix_05_01_logic.rb` (220 lines), `app/models/reports/base_logic.rb` (214 lines)
- Cause: Accumulated business logic in single classes; mixed concerns
- Improvement path: Extract calculation logic into service objects, separate presentation from business logic

**Multiple find_by_sql Calls in View Model:**
- Problem: `VMonthlyLedger` executes many separate raw SQL queries for different aggregation needs
- Files: `app/models/v_monthly_ledger.rb`
- Cause: Each reporting method builds separate SQL query; repeated table joins
- Improvement path: Consider materialized view approach, combine queries, implement query result caching

**Nested Asset Depreciation Logic:**
- Problem: `PayrollLogic` performs multiple nested loops with database queries for each employee
- Files: `app/models/payroll_info/payroll_logic.rb`
- Cause: Line-by-line calculation requirements; no batch processing
- Improvement path: Implement batch query loading, add caching layer for salary calculations

## Fragile Areas

**View Attribute Handler (Complex State Management):**
- Files: `app/controllers/base/view_attribute_handler.rb` (226 lines)
- Why fragile: Manages complex UI state across multiple controllers; many attr_accessor fields
- Safe modification: Add tests before modifying state initialization, document each accessor purpose, consider splitting into concerns
- Test coverage: Unclear; recommend integration tests for view state transitions

**BasicMasterController (Generic CRUD Base):**
- Files: `app/controllers/base/basic_master_controller.rb` (308 lines)
- Why fragile: Heavy use of metaprogramming, eval() calls, accepts polymorphic models
- Safe modification: Add strong parameter handling, replace eval with explicit constants, add controller-level tests
- Test coverage: Limited; recommend testing each action with real model types

**Simple Slip Model (Complex Validation):**
- Files: `app/models/simple_slip.rb` (297 lines)
- Why fragile: Validates multiple conditions, integrates with journal creation, handles currency conversions
- Safe modification: Extract validators into separate validator classes, test edge cases thoroughly before changes
- Test coverage: Should verify all validation branches and journal integration scenarios

**Journal Model (Core Business Logic):**
- Files: `app/models/journal.rb` (380 lines)
- Why fragile: Central to accounting operations, multiple associations, complex callbacks
- Safe modification: Test all before_save/after_save callbacks, verify cascade delete behavior, test with nested attributes
- Test coverage: Critical - requires comprehensive tests for all state transitions

## Scaling Limits

**Database Queries for Reports:**
- Current capacity: Designed for small-to-medium company accounting (tested with <100K journals)
- Limit: Report generation with raw SQL queries will slow with millions of journal entries
- Scaling path: Implement report materialization, add database indices strategically, consider time-series partitioning for old data

**File Upload/Storage:**
- Current capacity: Uses Carrierwave with local filesystem or S3 backend; no documented size limits
- Limit: Receipt storage could grow unbounded; no retention policy visible
- Scaling path: Implement file expiration, add storage quotas per company, archive old receipts

**Session Storage:**
- Current capacity: Uses activerecord-session_store; sessions stored in database
- Limit: Large number of concurrent users will create session bloat
- Scaling path: Migrate to Redis backend for sessions, implement session cleanup policy

**Payroll Processing:**
- Current capacity: Processes individual payrolls sequentially; no batch processing visible
- Limit: Large organizations (500+ employees) will experience slow payroll cycles
- Scaling path: Implement background job processing (Sidekiq), batch processing for payroll calculations

## Dependencies at Risk

**Turbolinks Gem (~> 5):**
- Risk: Deprecated and unmaintained; replaced by Turbo in modern Rails
- Impact: May have security vulnerabilities; incompatible with future Rails versions
- Migration plan: Replace with Rails 8 native Turbo, test AJAX interactions thoroughly

**CarrierWave for File Upload:**
- Risk: Actively maintained but newer alternatives (ActiveStorage) are Rails-integrated
- Impact: Additional gem dependency; integration points may diverge from Rails conventions
- Migration plan: Consider migration to ActiveStorage for new file features, maintain current for backward compatibility

**jQuery & jQuery UI (~> 4.5.1):**
- Risk: jQuery becoming less essential as native JavaScript modernizes; limited updates
- Impact: Bloated asset pipeline, security concerns if vulnerabilities discovered
- Migration plan: Gradual migration to vanilla JavaScript or modern framework, replace UI interactions with custom components

**Wicked PDF (< 2.0.0):**
- Risk: Pinned to pre-2.0 version with unclear support status
- Impact: Missing bug fixes and improvements in newer versions
- Migration plan: Test upgrade to 2.0.0, evaluate alternative PDF libraries if incompatible

**will_paginate Gem:**
- Risk: Older pagination library; Kaminari is more modern alternative
- Impact: Limited customization options, no major security issues but maintenance concern
- Migration plan: Evaluate replacement with Kaminari if pagination needs become more complex

**mimemagic Gem:**
- Risk: Had licensing issues in past; now maintained but niche use case
- Impact: Dependency for file type detection; could be replaced with built-in Ruby functionality
- Migration plan: Evaluate if file type validation is still needed, consider using libmagic directly

**Dalli (< 5.0.0):**
- Risk: Pinned below 5.0.0; version constraint suggests past incompatibility
- Impact: Missing cache performance improvements
- Migration plan: Test upgrade to 5.0.0+, review Memcached configuration

**remotipart Gem:**
- Risk: Unmaintained since Rails 5+; built-in file upload handling sufficient
- Impact: Dead code path if using standard Rails file handling
- Migration plan: Audit actual usage, remove if not actively used

## Missing Critical Features

**No Explicit Authorization Framework:**
- Problem: Only authentication (Devise) implemented; authorization at controller level is ad-hoc
- Blocks: Role-based access control, multi-tenancy enforcement, audit trails
- Recommendation: Implement Pundit or CanCanCan for formal authorization; audit all company_id access checks

**No Background Job Processing:**
- Problem: All processing is synchronous in request-response cycle
- Blocks: Batch processing (payroll, closing, exports), email notifications, report generation at scale
- Recommendation: Implement Sidekiq with Redis, move long-running operations to background jobs

**No Request/Response Logging Audit Trail:**
- Problem: No visible audit logging of who accessed/modified what data
- Blocks: Compliance with financial regulations (SOX, tax audit trails), debugging user actions
- Recommendation: Implement request logging middleware, audit trail gem (PaperTrail), or database triggers for sensitive tables

**No API Documentation:**
- Problem: XML endpoints exist but undocumented
- Blocks: Third-party integrations, mobile app development
- Recommendation: Add Swagger/OpenAPI documentation, implement versioning if external API planned

**No Error Tracking Service:**
- Problem: Errors logged locally; no central error tracking
- Blocks: Production debugging, error trend analysis, proactive issue detection
- Recommendation: Integrate Sentry or Rollbar for error tracking and alerting

## Test Coverage Gaps

**Model Validation Tests:**
- What's not tested: Complex validation chains in `Journal`, `SimpleSlip`, and `Payroll` models
- Files: `app/models/journal.rb`, `app/models/simple_slip.rb`, `app/models/payroll.rb`
- Risk: Validation rules may be bypassed; invalid states created; data integrity issues
- Priority: High - critical to accounting accuracy

**Controller Authorization Tests:**
- What's not tested: Company isolation; multi-tenant access control enforcement
- Files: `app/controllers/**/*_controller.rb`
- Risk: Users could access/modify other companies' data
- Priority: High - security and compliance critical

**Report Generation Logic Tests:**
- What's not tested: Edge cases in tax calculations, report appendix generation
- Files: `app/models/reports/**/*_logic.rb`
- Risk: Incorrect financial reports; tax calculation errors; regulatory non-compliance
- Priority: High - direct impact on financial accuracy

**Payroll Calculation Tests:**
- What's not tested: Tax withholding edge cases, insurance deduction combinations
- Files: `app/models/payroll_info/payroll_logic.rb`
- Risk: Incorrect payroll processing; employee disputes; regulatory violations
- Priority: High - financial and legal impact

**Integration Tests:**
- What's not tested: End-to-end workflows (journal entry → report generation → closing)
- Files: All model/controller integration
- Risk: Workflows may break with changes to intermediate components
- Priority: Medium - important for regression prevention

**Database Query Performance Tests:**
- What's not tested: Query optimization, N+1 detection
- Files: Report queries, payroll calculations
- Risk: Silent performance degradation as data grows
- Priority: Medium - important for scalability

---

*Concerns audit: 2026-04-12*
