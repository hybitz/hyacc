# External Integrations

**Analysis Date:** 2026-04-12

## APIs & External Services

**Google OAuth2:**
- Service: Google identity and access management
- What it's used for: User authentication and sign-in alternative to password login
- SDK/Client: `omniauth-google-oauth2` 1.2.2
- Auth method: OAuth2 flow via OmniAuth
- Implementation: `app/controllers/users/omniauth_callbacks_controller.rb` (GoogleCallback handler)
- User mapping: Email-based lookup via `User.from_omniauth()` - `app/models/user.rb`
- Routes: `devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }` - `config/routes.rb` line 5

**Yahoo Japan Furigana Service:**
- Service: Japanese text-to-phonetic conversion API
- What it's used for: Converting Japanese characters to furigana (phonetic reading) in simple slip templates
- Endpoint: `https://jlp.yahooapis.jp/FuriganaService/V2/furigana`
- Auth: App ID via environment variable `YAHOO_API_APP_ID`
- HTTP Method: POST with JSON payload
- Implementation: `app/controllers/mm/simple_slip_templates_controller.rb` - `get_keywords()` method (lines 75-80+)
- Requires: `YAHOO_API_APP_ID` environment variable for API authentication

## Data Storage

**Databases:**

**MySQL (Production):**
- Type: MySQL 5.7+ or MariaDB
- Client: mysql2 gem 0.5.7
- Connection: Configured via `config/database.yml`
- Environment variables:
  - `MYSQL_HOST` (default: 127.0.0.1)
  - `MYSQL_PORT` (default: 3306)
  - `MYSQL_USER` (default: hyacc)
  - `MYSQL_PASSWORD` (default: hyacc)
  - `RAILS_MAX_THREADS` (default: 5)
- Databases:
  - `hyacc_dev` - Development
  - `hyacc_test` - Testing
  - `hyacc_pro` - Production
- Character set: utf8mb4
- Collation: utf8mb4_general_ci

**SQLite3 (Development/Test):**
- Type: SQLite3 1.7.3
- Used for: Local development and testing
- File-based storage

**File Storage:**

**Local Filesystem (Default):**
- Service: Disk storage via ActiveStorage
- Root paths:
  - Development: `storage/`
  - Test: `tmp/storage/`
- Configured in `config/storage.yml` lines 1-7 and `config/initializers/`
- Uploaders:
  - `ReceiptUploader` - `app/uploaders/receipt_uploader.rb` (receipt file uploads)
  - `LogoUploader` - `app/uploaders/logo_uploader.rb` (company logo uploads)
- Framework: CarrierWave 3.1.2 with custom base uploader via Daddy gem
- Storage directory pattern: `{table_name}/{journal_id}/` for receipts

**AWS S3 (Optional, Commented Out):**
- Configuration template in `config/storage.yml` lines 12-15
- Would require: AWS credentials via Rails credentials
- Access key ID and secret key via `Rails.application.credentials.dig(:aws, :access_key_id|secret_access_key)`

**Caching:**
- Development: In-memory cache store (`:memory_store`)
- Test: Null cache store
- Production: Commented out, defaults to in-process memory (can enable Memcached with Dalli gem 4.3.3)

## Authentication & Identity

**Auth Provider:**
- Google OAuth2 (via OmniAuth)
- Custom password authentication (via Devise with bcrypt)

**Implementation:**
- Framework: Devise 5.0.3 with devise-i18n 1.16.0
- Password hashing: bcrypt 3.1.22 (stretches: 10 in production, 1 in test)
- Session storage: ActiveRecord database (secure cookies in production)
- Authentication keys: `login_id` (configured in `config/initializers/devise.rb` lines 32, 44, 49)
- Secret key: `SECRET_KEY_BASE` environment variable - `config/initializers/devise.rb` line 7
- OmniAuth providers: `:google_oauth2` (registered in User model `app/models/concerns/devise_aware.rb`)

**User Model:**
- Location: `app/models/user.rb`
- Google integration: `google_account` field for storing Google email
- Method: `User.from_omniauth(access_token)` - Maps Google OAuth provider to local user
- Callback: `Users::OmniauthCallbacksController#google_oauth2` - `app/controllers/users/omniauth_callbacks_controller.rb` lines 3-12

## Monitoring & Observability

**Error Tracking:**
- Not detected - No external error tracking service configured

**Logs:**
- Development: Rails default logger with console output
- Production: STDOUT with request ID tagging (`:request_id`)
- Log level: Controlled by `RAILS_LOG_LEVEL` environment variable (default: `info`)
- Health check path silenced: `/up` excluded from logs - `config/environments/production.rb` line 44
- Deprecation warnings: Not logged in production (`report_deprecations = false`) - `config/environments/production.rb` line 47

## CI/CD & Deployment

**Hosting:**
- Not explicitly configured for cloud platforms
- Appears to be self-hosted or container-based (Daddy gem suggests infrastructure-as-code approach)
- Production domain: `hyacc.reading.jp` (configured in `config/environments/production.rb` line 60)
- Reverse proxy assumed (via `config.assume_ssl` comments)

**Infrastructure Management:**
- Daddy 0.12.0 - Infrastructure and deployment management
- Configuration: `config/daddy.yml` with app name, environment, and web server (Passenger)
- Related gems: itamae, docker-api, ohai (server introspection)
- Supports Docker-based deployment (daddy gem includes docker-api integration)

**CI Pipeline:**
- CI Reporter 2.1.0 - CI integration support (not explicitly configured)
- Testing setup: Cucumber, Capybara, Minitest with SimpleCov coverage reporting

## Environment Configuration

**Required Environment Variables (Critical):**
- `MYSQL_HOST` - MySQL server hostname
- `MYSQL_PORT` - MySQL server port
- `MYSQL_USER` - MySQL database user
- `MYSQL_PASSWORD` - MySQL database password
- `RAILS_MAX_THREADS` - Database connection pool size
- `SECRET_KEY_BASE` - Devise/Rails encryption key (for sessions and auth)
- `YAHOO_API_APP_ID` - Yahoo Japan Furigana API authentication

**Optional Environment Variables:**
- `RAILS_LOG_LEVEL` - Logging verbosity (default: `info`)
- Credentials via Rails encrypted credentials system for SMTP, AWS, etc.

**Secrets Location:**
- `.env` file (via dotenv-rails) for development/test
- Rails encrypted credentials (`bin/rails credentials:edit`) for production
- Environment variables for deployment

## Webhooks & Callbacks

**Incoming:**
- No incoming webhooks detected

**Outgoing:**
- OmniAuth callback: Google OAuth2 redirect URI (configured in Google OAuth app)
- Expected callback path: `/users/auth/google_oauth2/callback` (Devise/OmniAuth default)

## Integration Patterns

**Authentication Flow:**
1. User initiates Google OAuth2 login
2. OmniAuth redirects to Google authorization endpoint
3. Google redirects back to `Users::OmniauthCallbacksController#google_oauth2`
4. Controller calls `User.from_omniauth()` to lookup/create user
5. Devise signs in user and redirects

**File Upload Flow:**
1. File uploaded via CarrierWave
2. ReceiptUploader processes file with metadata
3. Stored in local filesystem or S3 (if configured)
4. Original filename and deletion status tracked in database

**API Integration (Yahoo Furigana):**
1. Controller receives remarks text from simple slip template
2. Makes POST request to Yahoo Furigana Service with app ID
3. Parses JSON response with furigana conversion
4. Returns data to client via AJAX

---

*Integration audit: 2026-04-12*
