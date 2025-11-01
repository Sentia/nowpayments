# NOWPayments Ruby Gem

A Ruby client library for the [NOWPayments](https://nowpayments.io/) cryptocurrency payment processing API.

## Features

- **Standard Payments** - Accept cryptocurrency payments via API
- **Invoices** - Generate hosted payment pages
- **IPN Webhooks** - Secure webhook verification with HMAC-SHA512
- **Subscriptions** - Recurring payment management
- **Custody API** - Sub-account management for marketplaces and casinos
- **Mass Payouts** - Batch cryptocurrency payments
- **Error Handling** - Custom exception hierarchy with detailed context
- **Thread-Safe** - Auto-refreshing JWT token management
- **Well-Tested** - Comprehensive test suite with VCR cassettes

## Installation

**Note:** This gem is currently in development and not yet published to RubyGems.org.

Add this line to your application's Gemfile:

```ruby
gem 'nowpayments', git: 'https://github.com/Sentia/nowpayments'
```

Then execute:

```bash
bundle install
```

## Quick Start

```ruby
require 'nowpayments'

# Initialize the client
client = NOWPayments::Client.new(
  api_key: ENV['NOWPAYMENTS_API_KEY'],
  ipn_secret: ENV['NOWPAYMENTS_IPN_SECRET'],
  sandbox: true  # Use sandbox for testing
)

# Create a payment
payment = client.payments.create(
  price_amount: 100.0,
  price_currency: 'usd',
  pay_currency: 'btc',
  order_id: 'order-123'
)

# Verify an IPN webhook (in your Rails/Sinatra controller)
begin
  payload = NOWPayments::Webhook.verify!(
    request.body.read,
    request.headers['x-nowpayments-sig'],
    ENV['NOWPAYMENTS_IPN_SECRET']
  )
  
  if payload['payment_status'] == 'finished'
    # Payment complete - fulfill order
  end
rescue NOWPayments::SecurityError => e
  # Invalid signature - potential fraud attempt
  render status: 403
end
```

## Configuration

### API Credentials

You'll need the following credentials from your [NOWPayments Dashboard](https://nowpayments.io/):

1. **API Key** - For standard API authentication
2. **IPN Secret Key** - For webhook signature verification
3. **Email/Password** - For JWT-authenticated endpoints (Mass Payouts)

Store these securely using environment variables:

```bash
NOWPAYMENTS_API_KEY=your_api_key_here
NOWPAYMENTS_IPN_SECRET=your_ipn_secret_here
NOWPAYMENTS_SANDBOX_API_KEY=your_sandbox_key_here
```

### Sandbox Environment

NOWPayments provides a full-featured sandbox for testing. Enable it during initialization:

```ruby
client = NOWPayments::Client.new(
  api_key: ENV['NOWPAYMENTS_SANDBOX_API_KEY'],
  sandbox: true
)
```

## Usage

Comprehensive usage examples will be added as features are implemented. See `docs/` for detailed guides.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/nowpayments/client_spec.rb

# Run with coverage report
COVERAGE=true bundle exec rspec
```

### Sandbox Testing

To test against the NOWPayments Sandbox:

1. Create a [NOWPayments Sandbox account](https://account-sandbox.nowpayments.io/)
2. Generate API keys from the dashboard
3. Copy `.env.example` to `.env` and add your keys
4. Run tests with: `bundle exec rspec --tag sandbox`

### Documentation

Generate API documentation:

```bash
bundle exec yard doc
bundle exec yard server
```

## Architecture

This gem follows the Client/Resource pattern for clean separation of concerns:

```ruby
NOWPayments::Client               # Central configuration and HTTP client
├── NOWPayments::PaymentResource       # Standard payments
├── NOWPayments::InvoiceResource       # Hosted payment pages
├── NOWPayments::PayoutResource        # Mass payouts
├── NOWPayments::SubscriptionResource  # Recurring billing
└── NOWPayments::CustodyResource       # Sub-account management

NOWPayments::Webhook              # IPN verification utility
NOWPayments::Error                # Custom exception hierarchy
```

Built with:

- Faraday 2.x for HTTP with middleware architecture
- VCR cassettes for deterministic, fast tests against real API responses
- Client-side validation to catch errors before API calls
- Thread-safe JWT lifecycle management for auto-refreshing tokens
- Recursive key sorting for secure HMAC verification

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/Sentia/nowpayments](https://github.com/Sentia/nowpayments).

To contribute:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Ensure all tests pass (`bundle exec rspec`)
5. Run linter (`bundle exec rubocop`)
6. Commit your changes (`git commit -am 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Resources

- [NOWPayments Official API Documentation](https://documenter.getpostman.com/view/7907941/S1a32n38)
- [NOWPayments Dashboard](https://nowpayments.io/)
- [NOWPayments Sandbox](https://account-sandbox.nowpayments.io/)
- [Issue Tracker](https://github.com/Sentia/nowpayments/issues)

---

**Note:** This is an unofficial client library and is not affiliated with or endorsed by NOWPayments.
