#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "nowpayments"
require "dotenv"

Dotenv.load

# Initialize client
client = NOWPayments::Client.new(
  api_key: ENV.fetch("NOWPAYMENTS_SANDBOX_API_KEY", nil),
  sandbox: true
)

puts "=== NOWPayments API Demo ===\n\n"

# 1. Check API status
puts "1. Checking API status..."
status = client.status
puts "   Status: #{status["message"]}\n\n"

# 2. Get available currencies
puts "2. Getting available currencies..."
currencies = client.currencies
puts "   Available: #{currencies["currencies"].first(10).join(", ")}...\n\n"

# 3. Get minimum amount
puts "3. Checking minimum amount for USD -> BTC..."
min = client.min_amount(currency_from: "usd", currency_to: "btc")
puts "   Minimum: #{min["min_amount"]} #{min["currency_to"]}\n\n"

# 4. Estimate price
puts "4. Estimating price for 100 USD in BTC..."
estimate = client.estimate(
  amount: 100,
  currency_from: "usd",
  currency_to: "btc"
)
puts "   Estimated: #{estimate["estimated_amount"]} BTC\n\n"

# 5. Create a payment
puts "5. Creating a payment..."
payment = client.create_payment(
  price_amount: 100.0,
  price_currency: "usd",
  pay_currency: "btc",
  order_id: "demo-#{Time.now.to_i}",
  order_description: "Demo payment"
)
puts "   Payment ID: #{payment["payment_id"]}"
puts "   Pay Address: #{payment["pay_address"]}"
puts "   Pay Amount: #{payment["pay_amount"]} #{payment["pay_currency"]}"
puts "   Status: #{payment["payment_status"]}\n\n"

# 6. Check payment status
puts "6. Checking payment status..."
status = client.payment(payment["payment_id"])
puts "   Current status: #{status["payment_status"]}\n\n"

# 7. Create an invoice
puts "7. Creating an invoice..."
invoice = client.create_invoice(
  price_amount: 50.0,
  price_currency: "usd",
  order_id: "invoice-#{Time.now.to_i}"
)
puts "   Invoice ID: #{invoice["id"]}"
puts "   Invoice URL: #{invoice["invoice_url"]}\n\n"

puts "=== Demo Complete ===\n"
puts "All endpoints working correctly!"
