source "https://rubygems.org"

ruby "3.2.2"

# Core
gem "rails", "~> 7.2.3"
gem "pg", "~> 1.5"
gem "puma", ">= 5.0"
gem "bootsnap", require: false

# Frontend
gem "tailwindcss-rails", "~> 3.3.1"
gem "jsbundling-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "sprockets-rails"
gem "importmap-rails"

# Authentication & Authorization
gem "devise"
gem "pundit"
 gem "json", "~> 2.7.0"
# File Uploads (images for properties & cars)
gem "image_processing", "~> 2.1"
gem "active_storage_validations"

# Arabic / Localization
gem "rails-i18n"
gem "i18n-js"

# RTL support & UI helpers
gem "simple_form"
gem "pagy"                # Pagination (lighter than kaminari)

# SEO-friendly URLs for Arabic content
gem "friendly_id"

# Background jobs (image processing, notifications)
gem "sidekiq"
gem "redis"

# Forms / Country data for Syria
gem "country_select"

# Environment variables
gem "dotenv-rails", groups: [:development, :test]

# Utilities
gem "money-rails"        # Prices in Syrian Pound (SYP) / USD
gem "phonelib"           # Phone number validation (Syrian format)
gem "geocoder"           # Location for agencies (Damascus, Aleppo, etc.)

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
end

group :development do
  gem "web-console"
  gem "letter_opener"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
end

# PDF generation
gem "prawn"
gem "prawn-table"

gem "wicked_pdf"
gem "wkhtmltopdf-binary"
gem "rqrcode", "~> 2.0"
