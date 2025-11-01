# NOWPayments Ruby SDK - API Reference

Complete API documentation with all available methods and usage examples.

## Table of Contents

- [Authentication](#authentication)
  - [JWT Authentication](#jwt-authentication)
- [Status API](#status-api)
- [Payments API](#payments-api)
- [Invoices API](#invoices-api)
- [Estimates API](#estimates-api)
- [Recurring Payments API](#recurring-payments-api)
- [Mass Payouts API](#mass-payouts-api)
- [Conversions API](#conversions-api)
- [Custody API](#custody-api)
- [Error Handling](#error-handling)

---

## Authentication

### Initialize Client

```ruby
require 'nowpayments'

# Production
client = NOWPayments::Client.new(
  api_key: ENV['NOWPAYMENTS_API_KEY'],
  ipn_secret: ENV['NOWPAYMENTS_IPN_SECRET'] # Optional, for webhook verification
)

# Sandbox (for testing)
client = NOWPayments::Client.new(
  api_key: ENV['NOWPAYMENTS_SANDBOX_API_KEY'],
  ipn_secret: ENV['NOWPAYMENTS_SANDBOX_IPN_SECRET'],
  sandbox: true
)
```

### JWT Authentication

Some endpoints require JWT authentication (token expires after 5 minutes):

**Required for:**
- Mass Payouts (create, verify, list)
- Conversions (all endpoints)
- Custody Operations (transfers, write-offs)
- Recurring Payments (delete)

#### `authenticate(email:, password:)`

Authenticate and obtain a JWT token (valid for 5 minutes).

```ruby
response = client.authenticate(
  email: 'your_email@example.com',
  password: 'your_password'
)
# => {"token" => "eyJhbGc..."}

# Token is automatically stored and injected in subsequent requests
```

#### `jwt_token(email:, password:)`

Get current JWT token, optionally refreshing if expired.

```ruby
# Get current token without refresh
token = client.jwt_token
# => "eyJhbGc..." or nil if expired/not authenticated

# Get token with auto-refresh if expired
token = client.jwt_token(
  email: 'your_email@example.com',
  password: 'your_password'
)
# => "eyJhbGc..."
```

#### `jwt_expired?`

Check if JWT token is expired or missing.

```ruby
client.jwt_expired? # => false
```

#### `jwt_time_remaining`

Get seconds until JWT token expires.

```ruby
client.jwt_time_remaining # => 287
```

#### `clear_jwt_token`

Manually clear stored JWT token (optional, for security).

```ruby
client.clear_jwt_token
client.jwt_expired? # => true
```

**Auto-refresh pattern:**

```ruby
EMAIL = 'your_email@example.com'
PASSWORD = 'your_password'

def ensure_authenticated(client, email, password)
  return unless client.jwt_expired?
  client.authenticate(email: email, password: password)
end

# Before each JWT-required operation
ensure_authenticated(client, EMAIL, PASSWORD)
payout = client.create_payout(...)
```

---

## Status API

### `status`

Get API status (uptime, latency).

```ruby
status = client.status
# => {"message" => "OK"}
```

### `currencies`

Get list of available currencies.

```ruby
currencies = client.currencies
# => {"currencies" => ["btc", "eth", "usdt", ...]}
```

### `currencies_full`

Get detailed currency information including logos, networks, and limits.

```ruby
currencies = client.currencies_full
# => {"currencies" => [{"currency" => "btc", "logo_url" => "...", "network" => "BTC", ...}, ...]}
```

### `merchant_currencies`

Get currencies available to your merchant account.

```ruby
currencies = client.merchant_currencies
# => {"currencies" => ["btc", "eth", ...]}
```

### `selected_currencies`

Get currencies you've enabled in your account settings.

```ruby
currencies = client.selected_currencies
# => {"currencies" => ["btc", "eth", "usdt"]}
```

---

## Payments API

### `create_payment(price_amount:, price_currency:, pay_currency:, **params)`

Create a new payment.

```ruby
payment = client.create_payment(
  price_amount: 100.0,         # Amount in price_currency
  price_currency: 'usd',        # Fiat or crypto
  pay_currency: 'btc',          # Cryptocurrency customer pays with
  order_id: 'order-123',        # Your internal order ID
  order_description: 'Pro Plan - Annual',
  ipn_callback_url: 'https://example.com/webhooks/nowpayments',
  success_url: 'https://example.com/success',
  cancel_url: 'https://example.com/cancel'
)
# => {
#   "payment_id" => "5729887098",
#   "payment_status" => "waiting",
#   "pay_address" => "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh",
#   "pay_amount" => 0.00123456,
#   "pay_currency" => "btc",
#   "price_amount" => 100.0,
#   "price_currency" => "usd",
#   "order_id" => "order-123",
#   "expiration_estimate_date" => "2025-11-01T12:30:00.000Z"
# }
```

### `payment(payment_id)`

Get payment status and details.

```ruby
payment = client.payment('5729887098')
# => {
#   "payment_id" => "5729887098",
#   "payment_status" => "finished",
#   "pay_address" => "bc1q...",
#   "pay_amount" => 0.00123456,
#   "actually_paid" => 0.00123456,
#   "outcome_amount" => 99.5,
#   "outcome_currency" => "usd"
# }
```

**Payment statuses:**
- `waiting` - Waiting for customer to send cryptocurrency
- `confirming` - Payment received, waiting for confirmations
- `confirmed` - Payment confirmed
- `sending` - Sending to your wallet
- `partially_paid` - Customer sent wrong amount
- `finished` - Payment complete
- `failed` - Payment failed
- `refunded` - Payment refunded
- `expired` - Payment expired

### `minimum_payment_amount(currency_from:, currency_to:, fiat_equivalent:)`

Get minimum payment amount for a currency pair.

```ruby
minimum = client.minimum_payment_amount(
  currency_from: 'btc',
  currency_to: 'eth',
  fiat_equivalent: 'usd'
)
# => {
#   "currency_from" => "btc",
#   "currency_to" => "eth",
#   "fiat_equivalent" => "usd",
#   "min_amount" => 0.0001
# }
```

### `balance`

Get your account balance.

```ruby
balance = client.balance
# => {
#   "btc" => 0.5,
#   "eth" => 10.0,
#   "usdt" => 1000.0
# }
```

---

## Invoices API

Create hosted payment pages where customers can choose from 150+ cryptocurrencies.

### `create_invoice(price_amount:, price_currency:, order_id:, **params)`

Create a payment invoice with hosted page.

```ruby
invoice = client.create_invoice(
  price_amount: 99.0,
  price_currency: 'usd',
  order_id: "inv-#{order.id}",
  order_description: 'Pro Plan - Monthly',
  success_url: 'https://example.com/thank-you',
  cancel_url: 'https://example.com/checkout',
  ipn_callback_url: 'https://example.com/webhooks/nowpayments'
)
# => {
#   "id" => "5824448584",
#   "order_id" => "inv-123",
#   "order_description" => "Pro Plan - Monthly",
#   "price_amount" => 99.0,
#   "price_currency" => "usd",
#   "invoice_url" => "https://nowpayments.io/payment/?iid=5824448584",
#   "created_at" => "2025-11-01T12:00:00.000Z"
# }

# Redirect customer to invoice_url
redirect_to invoice['invoice_url']
```

### `invoice(invoice_id)`

Get invoice details and payment status.

```ruby
invoice = client.invoice('5824448584')
# => {
#   "id" => "5824448584",
#   "payment_status" => "finished",
#   "pay_currency" => "btc",
#   "pay_amount" => 0.00234567,
#   ...
# }
```

---

## Estimates API

### `estimate(amount:, currency_from:, currency_to:)`

Estimate exchange amount between currencies.

```ruby
estimate = client.estimate(
  amount: 100,
  currency_from: 'usd',
  currency_to: 'btc'
)
# => {
#   "currency_from" => "usd",
#   "amount_from" => 100,
#   "currency_to" => "btc",
#   "estimated_amount" => 0.00234567
# }
```

---

## Recurring Payments API

Create and manage subscription billing.

### `create_recurring_payment(price_amount:, price_currency:, pay_currency:, **params)`

Create a recurring payment plan.

```ruby
subscription = client.create_recurring_payment(
  price_amount: 29.99,
  price_currency: 'usd',
  pay_currency: 'btc',
  order_id: "sub-#{subscription.id}",
  order_description: 'Monthly Subscription',
  period: 'month',  # 'day', 'week', 'month', 'year'
  ipn_callback_url: 'https://example.com/webhooks/nowpayments'
)
# => {
#   "id" => "recurring_123",
#   "order_id" => "sub-456",
#   "price_amount" => 29.99,
#   "price_currency" => "usd",
#   "pay_currency" => "btc",
#   "period" => "month",
#   "status" => "active"
# }
```

### `recurring_payment(recurring_payment_id)`

Get recurring payment details.

```ruby
subscription = client.recurring_payment('recurring_123')
# => {
#   "id" => "recurring_123",
#   "status" => "active",
#   "next_payment_date" => "2025-12-01T00:00:00.000Z",
#   ...
# }
```

### `delete_recurring_payment(recurring_payment_id)`

**Requires JWT authentication.**

Cancel a recurring payment.

```ruby
# Authenticate first
client.authenticate(email: 'your@email.com', password: 'password')

# Delete recurring payment
result = client.delete_recurring_payment('recurring_123')
# => {"result" => true}
```

---

## Mass Payouts API

**All payout endpoints require JWT authentication.**

### `create_payout(withdrawals:, **params)`

**Requires JWT authentication.**

Create a batch payout to multiple addresses.

```ruby
# Authenticate first
client.authenticate(email: 'your@email.com', password: 'password')

# Create payout
payout = client.create_payout(
  withdrawals: [
    {
      address: 'TEmGwPeRTPiLFLVfBxXkSP91yc5GMNQhfS',
      currency: 'trx',
      amount: 10,
      extra_id: nil  # Required for some currencies (XRP, XLM, etc.)
    },
    {
      address: '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb',
      currency: 'eth',
      amount: 0.1
    }
  ],
  payout_description: 'Weekly affiliate payouts'
)
# => {
#   "id" => "batch_123",
#   "withdrawals" => [
#     {
#       "id" => "withdrawal_456",
#       "address" => "TEmGw...",
#       "currency" => "trx",
#       "amount" => 10,
#       "status" => "pending"
#     },
#     ...
#   ]
# }
```

### `verify_payout(batch_withdrawal_id:, verification_code:)`

**Requires JWT authentication.**

Verify payout with 2FA code (from Google Authenticator or email).

```ruby
# Authenticate first
client.authenticate(email: 'your@email.com', password: 'password')

# Verify with 2FA code
result = client.verify_payout(
  batch_withdrawal_id: 'batch_123',
  verification_code: '123456'  # From Google Authenticator
)
# => {"result" => true}
```

### `list_payouts(limit:, offset:)`

**Requires JWT authentication.**

List all payouts.

```ruby
# Authenticate first
client.authenticate(email: 'your@email.com', password: 'password')

# List payouts
payouts = client.list_payouts(limit: 10, offset: 0)
# => {
#   "count" => 5,
#   "data" => [
#     {
#       "id" => "batch_123",
#       "status" => "verified",
#       "created_at" => "2025-11-01T12:00:00.000Z",
#       ...
#     },
#     ...
#   ]
# }
```

---

## Conversions API

**All conversion endpoints require JWT authentication.**

Convert between cryptocurrencies at market rates.

### `create_conversion(from_currency:, to_currency:, amount:)`

**Requires JWT authentication.**

Create a currency conversion.

```ruby
# Authenticate first
client.authenticate(email: 'your@email.com', password: 'password')

# Create conversion
conversion = client.create_conversion(
  from_currency: 'btc',
  to_currency: 'eth',
  amount: 0.1
)
# => {
#   "conversion_id" => "conversion_123",
#   "from_currency" => "btc",
#   "to_currency" => "eth",
#   "from_amount" => 0.1,
#   "to_amount" => 2.5,
#   "status" => "processing"
# }
```

### `conversion_status(conversion_id)`

**Requires JWT authentication.**

Check conversion status.

```ruby
# Authenticate first
client.authenticate(email: 'your@email.com', password: 'password')

# Check status
status = client.conversion_status('conversion_123')
# => {
#   "conversion_id" => "conversion_123",
#   "status" => "completed",
#   "from_currency" => "btc",
#   "to_currency" => "eth",
#   "from_amount" => 0.1,
#   "to_amount" => 2.5
# }
```

### `list_conversions(limit:, offset:)`

**Requires JWT authentication.**

List all conversions.

```ruby
# Authenticate first
client.authenticate(email: 'your@email.com', password: 'password')

# List conversions
conversions = client.list_conversions(limit: 10, offset: 0)
# => {
#   "count" => 3,
#   "data" => [
#     {
#       "conversion_id" => "conversion_123",
#       "status" => "completed",
#       "created_at" => "2025-11-01T12:00:00.000Z",
#       ...
#     },
#     ...
#   ]
# }
```

---

## Custody API

Manage sub-accounts for users (marketplaces, casinos, exchanges).

### `create_sub_account(user_id:)`

Create a sub-account for a user.

```ruby
sub_account = client.create_sub_account(user_id: 'user_123')
# => {
#   "result" => {
#     "id" => 123456,
#     "user_id" => "user_123",
#     "created_at" => "2025-11-01T12:00:00.000Z"
#   }
# }
```

### `create_sub_account_deposit(user_id:, currency:)`

Generate deposit address for user's wallet.

```ruby
deposit = client.create_sub_account_deposit(
  user_id: 'user_123',
  currency: 'btc'
)
# => {
#   "result" => {
#     "user_id" => "user_123",
#     "currency" => "btc",
#     "address" => "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh"
#   }
# }
```

### `sub_account_balances(user_id:)`

Get user's sub-account balance.

```ruby
balances = client.sub_account_balances(user_id: 'user_123')
# => {
#   "result" => {
#     "balances" => {
#       "btc" => 0.5,
#       "eth" => 10.0,
#       "usdt" => 1000.0
#     }
#   }
# }
```

### `transfer_to_sub_account(user_id:, currency:, amount:)`

Transfer funds from main account to sub-account.

```ruby
transfer = client.transfer_to_sub_account(
  user_id: 'user_123',
  currency: 'btc',
  amount: 0.1
)
# => {
#   "result" => {
#     "id" => "transfer_456",
#     "user_id" => "user_123",
#     "currency" => "btc",
#     "amount" => 0.1,
#     "status" => "completed"
#   }
# }
```

### `transfer_between_sub_accounts(currency:, amount:, from_id:, to_id:)`

**Requires JWT authentication.**

Transfer between two sub-accounts.

```ruby
# Authenticate first
client.authenticate(email: 'your@email.com', password: 'password')

# Transfer between users
transfer = client.transfer_between_sub_accounts(
  currency: 'btc',
  amount: 0.05,
  from_id: 'user_123',
  to_id: 'user_456'
)
# => {
#   "result" => {
#     "id" => "transfer_789",
#     "from_id" => "user_123",
#     "to_id" => "user_456",
#     "currency" => "btc",
#     "amount" => 0.05,
#     "status" => "completed"
#   }
# }
```

### `withdraw_from_sub_account(user_id:, currency:, amount:, address:)`

Withdraw funds from sub-account to external address.

```ruby
withdrawal = client.withdraw_from_sub_account(
  user_id: 'user_123',
  currency: 'btc',
  amount: 0.05,
  address: 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh'
)
# => {
#   "result" => {
#     "id" => "withdrawal_789",
#     "user_id" => "user_123",
#     "currency" => "btc",
#     "amount" => 0.05,
#     "address" => "bc1q...",
#     "status" => "processing"
#   }
# }
```

### `write_off_sub_account_balance(user_id:, currency:, amount:, external_id:)`

**Requires JWT authentication.**

Write off (deduct) balance from sub-account.

```ruby
# Authenticate first
client.authenticate(email: 'your@email.com', password: 'password')

# Write off balance
result = client.write_off_sub_account_balance(
  user_id: 'user_123',
  currency: 'btc',
  amount: 0.01,
  external_id: 'fee_charge_789'
)
# => {
#   "result" => {
#     "user_id" => "user_123",
#     "currency" => "btc",
#     "amount" => 0.01,
#     "external_id" => "fee_charge_789",
#     "status" => "completed"
#   }
# }
```

---

## Error Handling

The SDK raises specific exceptions for different error types:

```ruby
begin
  payment = client.create_payment(...)
  
rescue NOWPayments::AuthenticationError => e
  # 401 - Invalid API key
  puts "Authentication failed: #{e.message}"
  
rescue NOWPayments::BadRequestError => e
  # 400 - Invalid parameters
  puts "Bad request: #{e.message}"
  puts "Details: #{e.body}"
  
rescue NOWPayments::NotFoundError => e
  # 404 - Resource not found
  puts "Not found: #{e.message}"
  
rescue NOWPayments::UnprocessableEntityError => e
  # 422 - Validation errors
  puts "Validation failed: #{e.message}"
  
rescue NOWPayments::RateLimitError => e
  # 429 - Too many requests
  retry_after = e.headers['Retry-After']
  puts "Rate limited. Retry after #{retry_after} seconds"
  
rescue NOWPayments::ServerError => e
  # 500 - NOWPayments server error
  puts "Server error: #{e.message}"
  
rescue NOWPayments::SecurityError => e
  # Webhook signature verification failed
  puts "Security error: #{e.message}"
  
rescue NOWPayments::ConnectionError => e
  # Network/connection error
  puts "Connection error: #{e.message}"
  
rescue NOWPayments::Error => e
  # Generic API error
  puts "API error: #{e.message}"
end
```

**Exception hierarchy:**

```
NOWPayments::Error
├── NOWPayments::AuthenticationError (401)
├── NOWPayments::BadRequestError (400)
├── NOWPayments::NotFoundError (404)
├── NOWPayments::UnprocessableEntityError (422)
├── NOWPayments::RateLimitError (429)
├── NOWPayments::ServerError (5xx)
├── NOWPayments::SecurityError (webhook verification)
└── NOWPayments::ConnectionError (network)
```

---

## Webhook Verification

**Critical:** Always verify webhook signatures to prevent fraud.

```ruby
# Rails controller
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def nowpayments
    # Verify signature - raises SecurityError if invalid
    payload = NOWPayments::Rack.verify_webhook(
      request,
      ENV['NOWPAYMENTS_IPN_SECRET']
    )
    
    # Process payment
    order = Order.find_by(id: payload['order_id'])
    
    case payload['payment_status']
    when 'finished'
      order.mark_paid!
    when 'failed', 'expired'
      order.cancel!
    end
    
    head :ok
    
  rescue NOWPayments::SecurityError => e
    logger.error "Invalid webhook: #{e.message}"
    head :forbidden
  end
end
```

**Signature verification (low-level):**

```ruby
require 'openssl'

def verify_signature(payload, signature, secret)
  hmac = OpenSSL::HMAC.hexdigest('SHA512', secret, payload)
  
  # Use constant-time comparison to prevent timing attacks
  secure_compare(hmac, signature)
end

def secure_compare(a, b)
  return false unless a.bytesize == b.bytesize
  
  l = a.unpack("C*")
  r = 0
  i = -1
  
  b.each_byte { |byte| r |= byte ^ l[i += 1] }
  r == 0
end
```

---

## Rate Limits

**Standard limits:**
- 60 requests per minute (standard endpoints)
- 10 requests per minute (payment creation)

**Best practices:**
- Implement exponential backoff on rate limit errors
- Cache currency lists and static data
- Use batch operations (payouts, invoices) when possible
- Monitor `Retry-After` header in rate limit responses

```ruby
def with_retry(max_retries: 3)
  retries = 0
  
  begin
    yield
  rescue NOWPayments::RateLimitError => e
    retries += 1
    if retries <= max_retries
      retry_after = e.headers['Retry-After'].to_i
      sleep retry_after
      retry
    else
      raise
    end
  end
end

# Usage
with_retry do
  client.create_payment(...)
end
```

---

## Testing

**Use sandbox for development:**

```ruby
client = NOWPayments::Client.new(
  api_key: ENV['NOWPAYMENTS_SANDBOX_API_KEY'],
  sandbox: true
)
```

**Get sandbox credentials:**
1. Create account at https://account-sandbox.nowpayments.io/
2. Generate API key from dashboard
3. Generate IPN secret for webhooks
4. Test with sandbox cryptocurrencies

**Sandbox test currencies:**
- All major cryptocurrencies available
- Instant confirmations (no waiting)
- Test payouts without real funds
- Test webhooks with ngrok

---

## Support

- [GitHub Issues](https://github.com/Sentia/nowpayments/issues)
- [NOWPayments Support](https://nowpayments.io/help)
- [API Documentation](https://documenter.getpostman.com/view/7907941/2s93JusNJt)
- [Sandbox Dashboard](https://account-sandbox.nowpayments.io/)
- [Production Dashboard](https://nowpayments.io/)
