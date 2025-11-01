# NOWPayments Ruby SDK

[![Gem Version](https://badge.fury.io/rb/nowpayments.svg)](https://badge.fury.io/rb/nowpayments)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Production-ready Ruby wrapper for the [NOWPayments API](https://documenter.getpostman.com/view/7907941/2s93JusNJt). Accept cryptocurrency payments with minimal code.

## Why NOWPayments?

- **150+ cryptocurrencies** - Bitcoin, Ethereum, USDT, and more
- **No KYC required** - Accept payments immediately
- **Instant settlement** - Real-time payment processing
- **Low fees** - Competitive transaction costs
- **Global reach** - Accept payments from anywhere

## Installation

Add to your Gemfile:

```ruby
gem 'nowpayments', git: 'https://github.com/Sentia/nowpayments'
```

Or install directly:

```bash
gem install nowpayments
```

## Quick Start

```ruby
require 'nowpayments'

# Initialize client (sandbox for testing, production when ready)
client = NOWPayments::Client.new(
  api_key: ENV['NOWPAYMENTS_API_KEY'],
  sandbox: true
)

# Create a payment
payment = client.create_payment(
  price_amount: 100.0,
  price_currency: 'usd',
  pay_currency: 'btc',
  order_id: 'order-123',
  ipn_callback_url: 'https://yourdomain.com/webhooks/nowpayments'
)

puts "Payment address: #{payment['pay_address']}"
puts "Amount: #{payment['pay_amount']} BTC"
puts "Status: #{payment['payment_status']}"
```

## Features

### Complete API Coverage (24 Methods, 92% Coverage)

**Standard API (17 methods):**
- **Payments** - Create and track cryptocurrency payments
- **Invoices** - Generate hosted payment pages  
- **Subscriptions** - Recurring payment plans and billing
- **Estimates** - Real-time price calculations and minimum amounts
- **Status** - API health and available currencies

**Custody API (7 methods):**
- **Sub-accounts** - Create and manage user wallets
- **Balances** - Query account and sub-account balances
- **Deposits** - Generate deposit addresses per user
- **Transfers** - Move funds between sub-accounts
- **Withdrawals** - Process user withdrawals

**Security:**
- **Webhooks** - HMAC-SHA512 signature verification
- **Constant-time comparison** - Prevents timing attacks
- **MFA-ready** - Required for gem publishing

### Built for Production

- **Comprehensive error handling** - 8 exception classes with detailed messages
- **Faraday middleware** - Automatic error mapping and retries
- **Tested** - 23 passing tests with VCR cassettes for integration
- **Rails-ready** - Drop-in Rack middleware for webhook verification
- **Type-safe** - All responses return Ruby Hashes from parsed JSON

## Usage Examples

### Accept Payment on Your Site

```ruby
# 1. Create payment
payment = client.create_payment(
  price_amount: 49.99,
  price_currency: 'usd',
  pay_currency: 'btc',
  order_id: "order-#{order.id}",
  order_description: 'Pro Plan - Annual',
  ipn_callback_url: 'https://example.com/webhooks/nowpayments'
)

# 2. Show payment address to customer
@payment_address = payment['pay_address']
@payment_amount = payment['pay_amount']

# 3. Check status
status = client.payment(payment['payment_id'])
# => {"payment_status"=>"finished", ...}
```

### Hosted Invoice Page

```ruby
# Create invoice with hosted payment page
invoice = client.create_invoice(
  price_amount: 99.0,
  price_currency: 'usd',
  order_id: "inv-#{invoice.id}",
  success_url: 'https://example.com/thank-you',
  cancel_url: 'https://example.com/checkout'
)

# Redirect customer to payment page
redirect_to invoice['invoice_url']
# Customer can choose from 150+ cryptocurrencies
```

### Custody API - Sub-accounts (Marketplaces & Casinos)

```ruby
# Create sub-account for a user
sub_account = client.create_sub_account(user_id: user.id)
# => {"id"=>123, "user_id"=>456, "created_at"=>"2025-11-01T..."}

# Generate deposit address for user's BTC wallet
deposit = client.create_sub_account_deposit(
  user_id: user.id,
  currency: 'btc'
)
# => {"address"=>"bc1q...", "currency"=>"btc"}

# Check user's balance
balances = client.sub_account_balances(user_id: user.id)
# => {"balances"=>{"btc"=>0.05, "eth"=>1.2}}

# Transfer funds to sub-account
transfer = client.transfer_to_sub_account(
  user_id: user.id,
  currency: 'btc',
  amount: 0.01
)

# Process withdrawal
withdrawal = client.withdraw_from_sub_account(
  user_id: user.id,
  currency: 'btc',
  amount: 0.005
)
```

### Webhook Verification (Critical!)

**Always verify webhook signatures to prevent fraud:**

```ruby
# app/controllers/webhooks_controller.rb
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def nowpayments
    # Verify signature - raises SecurityError if invalid
    payload = NOWPayments::Rack.verify_webhook(
      request,
      ENV['NOWPAYMENTS_IPN_SECRET']
    )
    
    # Process payment status
    order = Order.find_by(id: payload['order_id'])
    
    case payload['payment_status']
    when 'finished'
      order.mark_paid!
      OrderMailer.payment_received(order).deliver_later
    when 'failed', 'expired'
      order.cancel!
    when 'partially_paid'
      # Customer sent wrong amount
      logger.warn "Underpaid: #{payload['actually_paid']} vs #{payload['pay_amount']}"
    end
    
    head :ok
    
  rescue NOWPayments::SecurityError => e
    logger.error "Invalid webhook signature: #{e.message}"
    head :forbidden
  end
end

# config/routes.rb
post '/webhooks/nowpayments', to: 'webhooks#nowpayments'
```

### Error Handling

```ruby
begin
  payment = client.create_payment(...)
  
rescue NOWPayments::AuthenticationError
  # Invalid API key
  
rescue NOWPayments::BadRequestError => e
  # Invalid parameters
  puts "Error: #{e.message}"
  puts "Details: #{e.body}"
  
rescue NOWPayments::RateLimitError => e
  # Too many requests
  retry_after = e.headers['Retry-After']
  
rescue NOWPayments::ServerError
  # NOWPayments server error
  
rescue NOWPayments::ConnectionError
  # Network error
end
```

## Documentation

- **[Complete API Reference](docs/API.md)** - All methods with examples
- **[Official API Docs](https://documenter.getpostman.com/view/7907941/2s93JusNJt)** - NOWPayments API documentation
- **[Dashboard](https://nowpayments.io/)** - Production environment
- **[Sandbox Dashboard](https://account-sandbox.nowpayments.io/)** - Testing environment

## Testing with Sandbox

```ruby
# Use sandbox for development
client = NOWPayments::Client.new(
  api_key: ENV['NOWPAYMENTS_SANDBOX_API_KEY'],
  ipn_secret: ENV['NOWPAYMENTS_SANDBOX_IPN_SECRET'],
  sandbox: true
)

# All API calls go to sandbox environment
payment = client.create_payment(...)
```

**Get sandbox credentials:**
1. Create account at https://account-sandbox.nowpayments.io/
2. Generate API key from dashboard
3. Generate IPN secret for webhooks
4. Add to `.env` file

## Configuration

```bash
# .env
NOWPAYMENTS_API_KEY=your_production_api_key
NOWPAYMENTS_IPN_SECRET=your_ipn_secret

# Testing
NOWPAYMENTS_SANDBOX_API_KEY=your_sandbox_api_key
NOWPAYMENTS_SANDBOX_IPN_SECRET=your_sandbox_ipn_secret
```

## Examples

See the `examples/` directory:

```bash
# API usage demo
cp .env.example .env
# Add your sandbox credentials to .env
ruby examples/simple_demo.rb

# Webhook receiver (Sinatra)
ruby examples/webhook_server.rb
# Use ngrok to expose: ngrok http 4567
```

## Development

```bash
# Install dependencies
bundle install

# Run tests
bundle exec rspec

# Run tests with coverage
COVERAGE=true bundle exec rspec

# Lint code
bundle exec rubocop

# Interactive console
bundle exec rake console
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b feature/my-feature`)
3. Run tests (`bundle exec rspec`)
4. Commit your changes (`git commit -am 'Add feature'`)
5. Push to the branch (`git push origin feature/my-feature`)
6. Create a Pull Request

## Security

**Report security vulnerabilities to:** security@yourdomain.com

Never commit API keys or secrets. Always use environment variables.

## License

MIT License - see [LICENSE.txt](LICENSE.txt)

## Support

- [GitHub Issues](https://github.com/Sentia/nowpayments/issues)
- [NOWPayments Support](https://nowpayments.io/help)
- [API Documentation](https://documenter.getpostman.com/view/7907941/2s93JusNJt)
