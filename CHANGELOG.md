# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2025-11-01

### Added - 100% API Coverage Achievement! 🎉
- **JWT Authentication Module (5 methods)**: Complete token lifecycle management
  - `authenticate(email:, password:)` - Get JWT token with 5-minute expiration
  - `jwt_token(email:, password:)` - Get token with optional auto-refresh
  - `jwt_expired?` - Check token validity
  - `clear_jwt_token` - Manual token clearing
  - `jwt_time_remaining` - Seconds until token expires
  - Automatic Bearer token injection in Authorization header
  - Connection reset mechanism on token change
- **Fiat Payouts Module (8 methods)**: Beta - Crypto to fiat withdrawals
  - `fiat_payout_payment_methods` - Get available payment methods
  - `create_fiat_payout_account` - Create payout account
  - `fiat_payout_accounts` - List payout accounts
  - `update_fiat_payout_account` - Update account details
  - `create_fiat_payout` - Create fiat payout
  - `fiat_payout_status` - Get payout status
  - `fiat_payouts` - List all payouts with 13 filter options
  - `fiat_payout_rates` - Get conversion rates
- **Invoice Status Method**: `invoice(invoice_id)` - Get invoice details and status
- **Mass Payouts (8 methods)**: Batch withdrawals with 2FA verification
  - `balance` - Get account balance
  - `create_payout` - Create batch payout (JWT required)
  - `verify_payout` - 2FA verification (JWT required)
  - `payout_status` - Get payout status
  - `list_payouts` - List all payouts (JWT required)
  - `validate_payout_address` - Validate withdrawal address
  - `min_payout_amount` - Get minimum payout amount
  - `payout_fee` - Calculate payout fee
- **Conversions Module (3 methods)**: Currency conversions (JWT required)
  - `create_conversion` - Convert between cryptocurrencies
  - `conversion_status` - Check conversion status
  - `list_conversions` - List all conversions
- **Custody/Sub-accounts Module (11 methods)**: User wallet management for marketplaces
  - `create_sub_account` - Create user account
  - `sub_account_balance` - Get user balance
  - `sub_account_balances` - Get all balances
  - `list_sub_accounts` - List all sub-accounts
  - `transfer_between_sub_accounts` - Transfer between users (JWT required)
  - `create_sub_account_deposit` - Generate deposit address
  - `create_sub_account_payment_deposit` - Payment to sub-account
  - `transfer_to_sub_account` - Deposit to user
  - `withdraw_from_sub_account` - Withdraw from user (JWT required)
  - `sub_account_transfer` - Get transfer details
  - `sub_account_transfers` - List all transfers
- **Subscriptions/Recurring Payments Module (9 methods)**: Complete subscription management
  - `subscription_plans` - List all plans
  - `create_subscription_plan` - Create new plan
  - `update_subscription_plan` - Update plan
  - `subscription_plan` - Get plan details
  - `create_subscription` - Create subscription
  - `list_recurring_payments` - List with filters
  - `recurring_payment` - Get subscription details
  - `delete_recurring_payment` - Cancel subscription (JWT required)
  - `subscription_payments` - List subscription payments

### Changed
- **Complete API Coverage**: Now 57 methods across 11 modules (was 44 methods across 9 modules)
- **Modular Architecture**: Split monolithic client (674 lines) into focused API modules (76-line client + 11 modules)
- **Documentation**: Updated README to 578 lines with complete method list, usage examples, and guides
- Version bump from 0.1.0 to 0.2.0 (minor version for new features)

### Documentation
- Added comprehensive API reference (docs/API.md - 950+ lines)
- Added JWT authentication examples (examples/jwt_authentication_example.rb - 10 usage patterns)
- Updated README with collapsible method lists and detailed usage guides
- Added currency conversions examples
- Added fiat payouts usage guide
- Added internal documentation for gap analysis and sprint reports

### Security
- JWT Bearer token support for protected endpoints
- Automatic token expiration management (5-minute lifetime)
- Secure token storage and injection
- All existing webhook security features maintained

### Breaking Changes
- None - All changes are additive and backward compatible

## [0.1.0] - 2025-01-XX

### Added
- Complete API client implementation with all NOWPayments v1 endpoints
- Payment API: create, retrieve, list with filters, update estimate
- Invoice API: create hosted payment pages with success/cancel URLs
- Subscription API: plans, create plan, get plan, create subscription, list payments
- Payout API: mass withdrawals support
- Estimation API: minimum amounts and price estimates
- Status & utility endpoints: API status, currencies, full currency info, merchant coins
- Comprehensive error handling with custom exception hierarchy (8 error types)
- Secure IPN webhook verification with HMAC-SHA512 and recursive key sorting
- Rack middleware for Rails/Sinatra webhook integration
- Faraday ErrorHandler middleware for automatic HTTP error mapping
- Sandbox environment support for testing
- VCR cassette support for reliable integration testing
- Complete RSpec test suite with WebMock integration
- Example scripts: simple demo and webhook server (Sinatra)
- Comprehensive API documentation (docs/API.md)
- Professional README with usage examples

### Changed
- Upgraded to Faraday 2.x with built-in JSON support (no faraday-json dependency)
- All API methods return raw Hash responses (no data models per design decision)

### Security
- Implemented constant-time signature comparison to prevent timing attacks
- Recursive key sorting for consistent HMAC signature generation
- Webhook signature verification with SecurityError on failure

[Unreleased]: https://github.com/Sentia/nowpayments/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/Sentia/nowpayments/releases/tag/v0.1.0

