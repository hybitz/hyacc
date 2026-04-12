# Technology Stack

**Analysis Date:** 2026-04-12

## Languages

**Primary:**
- Ruby 3.4.8 - Application code, Rails framework

**Secondary:**
- JavaScript - Frontend interactions, Turbolinks, jQuery
- HTML/ERB - View templates
- SCSS/CSS - Styling via Bootstrap and SassC

## Runtime

**Environment:**
- Ruby 3.4.8 (specified in `.ruby-version`)

**Package Manager:**
- Bundler (implicit via Gemfile)
- Lockfile: `Gemfile.lock` present with 649 dependencies resolved

## Frameworks

**Core:**
- Rails 8.1.3 - Web framework, ORM, routing, asset pipeline (`Gemfile` line 5)
- Puma 8.0.0 - Application server

**Authentication & Authorization:**
- Devise 5.0.3 - User authentication with password hashing via bcrypt (`Gemfile` lines 18-19)
- OmniAuth 2.1.4 - OAuth provider abstraction (`Gemfile` line 33)
- OmniAuth Google OAuth2 1.2.2 - Google OAuth2 integration (`Gemfile` line 34)
- OmniAuth Rails CSRF Protection 2.0.1 - CSRF protection for OmniAuth flows (`Gemfile` line 35)

**Frontend:**
- Bootstrap 5.3.8 - CSS framework (`Gemfile` line 12)
- Turbolinks 5.2.1 - SPA-like navigation without full reloads (`Gemfile` line 44)
- jQuery Rails 4.5.1 - jQuery integration (`Gemfile` line 25)
- jQuery UI Rails 8.0.0 - jQuery UI components (`Gemfile` line 26)
- Momentjs Rails 2.29.4.1 - Date/time library (`Gemfile` line 29)
- Fullcalendar Rails 3.9.0.0 - Calendar UI component (`Gemfile` line 22)
- Mousetrap Rails 1.4.6 - Keyboard shortcuts library (`Gemfile` line 30)
- Remotipart 1.4.4 - AJAX file upload support (`Gemfile` line 38)

**File Upload & Image Processing:**
- CarrierWave 3.1.2 - File upload handling (`Gemfile` line 13)
- CarrierWave i18n 3.1.0 - Localization for CarrierWave (`Gemfile` line 14)
- Mini Magick 4.13.2 - Image manipulation wrapper around ImageMagick (`Gemfile` line 28)
- Fog AWS 3.33.1 - AWS S3 support for file storage (`Gemfile` line 21)

**PDF Generation:**
- Wicked PDF 1.4.0 - PDF rendering using wkhtmltopdf (`Gemfile` line 46)
- Path: `/usr/local/bin/wkhtmltopdf` (configured in `config/initializers/wicked_pdf.rb` line 17)

**Domain-Specific:**
- Acts as Tree 2.9.1 - Hierarchical data (account tree structure) (`Gemfile` line 8)
- Tax JP 1.8.5 - Japanese tax calculations and forms (`Gemfile` line 43)
- Holiday JP 0.8.1 - Japanese holiday calendar (`Gemfile` line 23)
- Nostalgic - Rails engine (mounted in `config/routes.rb` line 8)

**Localization:**
- Rails i18n 8.1.0 - Internationalization framework (`Gemfile` line 37)
- Devise i18n 1.16.0 - Devise translations (`Gemfile` line 19)
- Default locale: Japanese (`:ja`), fallback to English (`:en`) - `config/application.rb` line 32

**HTTP & API:**
- Faraday 2.14.1 - HTTP client library for API calls (`Gemfile` line 20)

**Testing:**
- Cucumber 9.2.1 - BDD acceptance testing (`Gemfile` line 55)
- Cucumber Rails 4.0.1 - Rails integration for Cucumber (`Gemfile` line 69)
- Capybara 3.40.0 - Browser automation for feature tests (`Gemfile` line 66)
- Selenium WebDriver 4.43.0 - Browser driver for Capybara (`Gemfile` line 74)
- Minitest 5.27.0 - Unit testing framework (Rails default) (`Gemfile` line 71)
- Minitest Reporters 1.8.0 - Enhanced test output (`Gemfile` line 72)
- Rails Controller Testing 1.0.5 - Controller test helpers (`Gemfile` line 73)
- Database Cleaner 2.1.0 - Test database cleanup between tests (`Gemfile` line 70)
- Closer 0.18.3 - BDD testing utilities (`Gemfile` line 68)
- CI Reporter 2.1.0 - CI integration reporting (`Gemfile` line 67)
- Simplecov 0.22.0 - Code coverage analysis (`Gemfile` line 75)

**Development Tools:**
- Byebug 13.0.0 - Debugger (`Gemfile` line 54)
- Rack Mini Profiler 4.0.1 - Performance profiling (`Gemfile` line 60)
- Rails ERD 1.7.2 - Entity relationship diagram generation (`Gemfile` line 61)
- Web Console 4.3.0 - Interactive debugging in browser (`Gemfile` line 62)
- Dotenv Rails 3.2.0 - Environment variable management (`Gemfile` line 56)
- Bootsnap 1.23.0 - Boot time optimization (`Gemfile` line 11)

**Build & Asset Pipeline:**
- Sprockets Rails 3.5.2 - Asset pipeline integration (`Gemfile` line 40)
- SassC Rails 2.1.2 - SCSS compilation (`Gemfile` line 39)
- Uglifier 4.2.1 - JavaScript minification (`Gemfile` line 45)
- Jbuilder 2.14.1 - JSON response builder (`Gemfile` line 24)

**Session & Caching:**
- ActiveRecord Session Store 2.2.0 - Session storage in database (`Gemfile` line 7, `config/initializers/session_store.rb`)
- Dalli 4.3.3 - Memcached client (optional, not enabled by default) (`Gemfile` line 17)

**Database:**
- MySQL 0.5.7 (development/itamae group) - Production database driver (`Gemfile` line 50)
- SQLite3 1.7.3 - Development/test database (`Gemfile` line 41)

**Other Utilities:**
- Strong Actions 0.6.2 - Strong parameters enforcement (`Gemfile` line 42)
- Will Paginate 4.0.1 - Pagination (`Gemfile` line 47)
- Daddy 0.12.0 - Container/deployment management (`Gemfile` line 16)
- Nokogiri 1.19.2 - XML/HTML parsing (`Gemfile` line 32)
- Mimemagic 0.4.3 - MIME type detection (`Gemfile` line 27)
- Benchmark 0.5.0 - Performance benchmarking (`Gemfile` line 10)
- CSV 3.3.5 - CSV file handling (`Gemfile` line 15)

## Configuration

**Environment:**
- Configuration from `config/application.rb` (Rails 8.1 defaults)
- Environment-specific configs in `config/environments/development.rb`, `production.rb`, `test.rb`
- Timezone: Tokyo (`config/application.rb` line 28)
- ActiveRecord timezone handling: Local time (`config/application.rb` line 29)
- Parameters enforcement: Strict (raises on unpermitted parameters) - `config/application.rb` line 34

**Database:**
- Adapter: MySQL (production), SQLite3 (development/test)
- Configuration: `config/database.yml` with ERB environment variables
- Environment variables: `MYSQL_HOST`, `MYSQL_PORT`, `MYSQL_USER`, `MYSQL_PASSWORD`, `RAILS_MAX_THREADS`
- Default databases: `hyacc_dev` (dev), `hyacc_test` (test), `hyacc_pro` (prod)
- Character set: utf8mb4 with utf8mb4_general_ci collation

**File Storage:**
- Primary: Local filesystem (`:local` service in `config/storage.yml`)
- Development/Test: `storage/` and `tmp/storage/` directories
- AWS S3 support available but commented out in `config/storage.yml` lines 12-15
- ActiveStorage service configured via `config.active_storage.service` in environments

**Session Storage:**
- Method: ActiveRecord database store (secure in production)
- Configuration: `config/initializers/session_store.rb`
- Session key: `_hyacc_session`

**Caching:**
- Development: In-memory cache store (`:memory_store`)
- Test: Null cache store (no caching)
- Production: In-process memory (could be changed to memcached via `config.cache_store` in `config/environments/production.rb` line 50)

**Mailer:**
- Development: No error raising, cached responses disabled
- Production: Host set to `hyacc.reading.jp` with HTTPS protocol
- SMTP configuration available but commented out in `config/environments/production.rb` lines 63-69

## Platform Requirements

**Development:**
- Ruby 3.4.8
- Bundler for dependency management
- Node.js/npm optional (package.json present but no dependencies)
- ImageMagick (for Mini Magick)
- wkhtmltopdf binary at `/usr/local/bin/wkhtmltopdf` (for PDF generation)
- MySQL 5.7+ or MariaDB (for production database)
- SQLite3 (for development/test)

**Production:**
- Ruby 3.4.8
- Puma application server
- Reverse proxy with SSL termination (HTTPS enforced via `config.force_ssl = true`)
- MySQL 5.7+ or MariaDB
- ImageMagick
- wkhtmltopdf binary
- File storage (local filesystem or AWS S3)
- Optional: Memcached server (for distributed caching)

---

*Stack analysis: 2026-04-12*
