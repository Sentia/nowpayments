# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

