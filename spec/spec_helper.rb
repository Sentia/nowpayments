# frozen_string_literal: true

require "nowpayments"
require "vcr"
require "webmock/rspec"
require "pry"

# Load environment variables for testing
require "dotenv"
Dotenv.load

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# VCR configuration
VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!

  # Filter sensitive data from cassettes
  config.filter_sensitive_data("<API_KEY>") { ENV["NOWPAYMENTS_SANDBOX_API_KEY"] }
  config.filter_sensitive_data("<IPN_SECRET>") { ENV["NOWPAYMENTS_SANDBOX_IPN_SECRET"] }

  # Allow connections to sandbox when recording
  config.ignore_localhost = false
  config.allow_http_connections_when_no_cassette = false
end
