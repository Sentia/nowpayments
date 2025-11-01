# frozen_string_literal: true

# JWT Authentication Example

require "nowpayments"

# Initialize client with API key
client = NOWPayments::Client.new(
  api_key: "YOUR_API_KEY",
  sandbox: true # Use sandbox for testing
)

# ============================================
# Example 1: Basic Authentication
# ============================================

puts "Example 1: Basic JWT Authentication"
puts "=" * 50

# Authenticate to get JWT token (expires in 5 minutes)
auth_response = client.authenticate(
  email: "your_email@example.com",
  password: "your_password"
)

puts "✅ Authenticated successfully!"
puts "Token: #{auth_response["token"][0..20]}..."
puts "Time remaining: #{client.jwt_time_remaining} seconds"
puts

# ============================================
# Example 2: Operations Requiring JWT Auth
# ============================================

puts "Example 2: Creating a Payout (Requires JWT)"
puts "=" * 50

# Create a payout (requires JWT Bearer token)
payout_response = client.create_payout(
  withdrawals: [
    {
      address: "TEmGwPeRTPiLFLVfBxXkSP91yc5GMNQhfS",
      currency: "trx",
      amount: 10
    }
  ],
  payout_description: "Test payout"
)

puts "✅ Payout created!"
puts "Batch ID: #{payout_response["id"]}"
puts "Status: #{payout_response["withdrawals"].first["status"]}"
puts

# Verify payout with 2FA code
client.verify_payout(
  batch_withdrawal_id: payout_response["id"],
  verification_code: "123456" # From Google Authenticator or email
)

puts "✅ Payout verified!"
puts

# ============================================
# Example 3: Token Management
# ============================================

puts "Example 3: Token Lifecycle Management"
puts "=" * 50

# Check token status
puts "Token expired? #{client.jwt_expired?}"
puts "Time remaining: #{client.jwt_time_remaining} seconds"
puts

# Manual token refresh (if you have credentials stored)
if client.jwt_time_remaining < 60
  puts "⚠️  Token expiring soon, re-authenticating..."
  client.authenticate(
    email: "your_email@example.com",
    password: "your_password"
  )
  puts "✅ Token refreshed!"
end
puts

# ============================================
# Example 4: Conversions (Requires JWT)
# ============================================

puts "Example 4: Currency Conversions"
puts "=" * 50

# All conversion endpoints require JWT authentication
conversion = client.create_conversion(
  from_currency: "btc",
  to_currency: "eth",
  amount: 0.1
)

puts "✅ Conversion created!"
puts "Conversion ID: #{conversion["conversion_id"]}"
puts

# Check conversion status
status = client.conversion_status(conversion["conversion_id"])
puts "Status: #{status["status"]}"
puts

# ============================================
# Example 5: Custody Operations (Requires JWT)
# ============================================

puts "Example 5: Custody/Sub-Account Operations"
puts "=" * 50

# Create user account
user = client.create_sub_account(user_id: "user_12345")
puts "✅ User account created: #{user["result"]["id"]}"
puts

# Transfer between accounts (requires JWT)
transfer = client.transfer_between_sub_accounts(
  currency: "trx",
  amount: 5,
  from_id: "111111",
  to_id: "222222"
)

puts "✅ Transfer initiated!"
puts "Transfer ID: #{transfer["result"]["id"]}"
puts "Status: #{transfer["result"]["status"]}"
puts

# ============================================
# Example 6: Recurring Payments (DELETE requires JWT)
# ============================================

puts "Example 6: Managing Recurring Payments"
puts "=" * 50

# Delete recurring payment (requires JWT)
result = client.delete_recurring_payment("subscription_id")
puts "✅ Recurring payment deleted: #{result["result"]}"
puts

# ============================================
# Example 7: Token Cleanup
# ============================================

puts "Example 7: Token Cleanup"
puts "=" * 50

# Clear token when done (optional, for security)
client.clear_jwt_token
puts "✅ JWT token cleared"
puts "Token expired? #{client.jwt_expired?}"
puts

# ============================================
# Example 8: Auto-Refresh Pattern
# ============================================

puts "Example 8: Auto-Refresh Pattern"
puts "=" * 50

# Store credentials for auto-refresh
EMAIL = "your_email@example.com"
PASSWORD = "your_password"

# Helper method to ensure authenticated
def ensure_authenticated(client, email, password)
  return unless client.jwt_expired?

  puts "🔄 Token expired, re-authenticating..."
  client.authenticate(email: email, password: password)
  puts "✅ Re-authenticated!"
end

# Before each JWT-required operation
ensure_authenticated(client, EMAIL, PASSWORD)
payout = client.list_payouts(limit: 10, offset: 0)
puts "✅ Listed #{payout["count"]} payouts"
puts

# ============================================
# Example 9: Multiple Operations Pattern
# ============================================

puts "Example 9: Efficient Multiple Operations"
puts "=" * 50

# Authenticate once at the beginning
client.authenticate(
  email: "your_email@example.com",
  password: "your_password"
)

# Perform multiple operations (token valid for 5 minutes)
operations = [
  -> { client.balance },
  -> { client.list_payouts(limit: 5, offset: 0) },
  -> { client.list_conversions(limit: 5, offset: 0) },
  -> { client.sub_account_balances }
]

operations.each_with_index do |operation, index|
  # Check if token needs refresh before each operation
  if client.jwt_expired?
    puts "🔄 Refreshing token..."
    client.authenticate(
      email: "your_email@example.com",
      password: "your_password"
    )
  end

  result = operation.call
  puts "✅ Operation #{index + 1} completed"
rescue StandardError => e
  puts "❌ Operation #{index + 1} failed: #{e.message}"
end
puts

# ============================================
# Example 10: Error Handling
# ============================================

puts "Example 10: Error Handling"
puts "=" * 50

begin
  # Try to create payout without authentication
  client.clear_jwt_token
  client.create_payout(
    withdrawals: [{ address: "TEmGwPeRTPiLFLVfBxXkSP91yc5GMNQhfS", currency: "trx", amount: 10 }]
  )
rescue StandardError => e
  puts "❌ Expected error: #{e.class}"
  puts "Message: #{e.message}"
  puts "💡 Solution: Authenticate first!"
  puts

  # Authenticate and retry
  client.authenticate(
    email: "your_email@example.com",
    password: "your_password"
  )
  puts "✅ Authenticated, retry succeeded!"
end

puts
puts "=" * 50
puts "🎉 All JWT authentication examples completed!"
puts "=" * 50
