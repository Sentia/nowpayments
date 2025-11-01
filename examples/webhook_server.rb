# frozen_string_literal: true

# Example Sinatra webhook receiver
#
# Usage:
#   ruby examples/webhook_server.rb
#   Then use ngrok to expose: ngrok http 4567
#   Configure the ngrok URL in NOWPayments dashboard

require "sinatra"
require "nowpayments"
require "dotenv"
require "json"

Dotenv.load

# Configure logging
set :logging, true

# Webhook endpoint
post "/webhooks/nowpayments" do
  # Verify the webhook
  payload = NOWPayments::Rack.verify_webhook(
    request,
    ENV["NOWPAYMENTS_SANDBOX_IPN_SECRET"]
  )

  logger.info "Received verified webhook: #{payload.inspect}"

  # Handle different payment statuses
  case payload["payment_status"]
  when "finished"
    logger.info "✅ Payment #{payload["payment_id"]} completed!"
    logger.info "   Order: #{payload["order_id"]}"
    logger.info "   Amount: #{payload["outcome_amount"]} #{payload["outcome_currency"]}"

    # TODO: Fulfill order here
    # Order.find_by(id: payload['order_id'])&.mark_paid!

  when "failed"
    logger.warn "❌ Payment #{payload["payment_id"]} failed"

    # TODO: Cancel order here
    # Order.find_by(id: payload['order_id'])&.cancel!

  when "partially_paid"
    logger.warn "⚠️  Payment #{payload["payment_id"]} partially paid"
    logger.warn "   Expected: #{payload["pay_amount"]} #{payload["pay_currency"]}"
    logger.warn "   Received: #{payload["actually_paid"]} #{payload["pay_currency"]}"

  when "expired"
    logger.info "⏱️  Payment #{payload["payment_id"]} expired"

  else
    logger.info "ℹ️  Payment #{payload["payment_id"]} status: #{payload["payment_status"]}"
  end

  # Always return 200 OK to acknowledge receipt
  status 200
  { success: true }.to_json
rescue NOWPayments::SecurityError => e
  # Invalid signature - potential fraud
  logger.error "🔒 Security Error: #{e.message}"
  status 403
  { error: "Invalid signature" }.to_json
rescue StandardError => e
  # Other errors
  logger.error "❌ Error processing webhook: #{e.message}"
  logger.error e.backtrace.join("\n")
  status 500
  { error: "Internal server error" }.to_json
end

# Health check endpoint
get "/health" do
  { status: "ok", timestamp: Time.now.to_i }.to_json
end

# Start message
puts "\n=== NOWPayments Webhook Server ==="
puts "Listening on http://localhost:4567"
puts "Webhook URL: http://localhost:4567/webhooks/nowpayments"
puts "\nTo expose publicly, use ngrok:"
puts "  ngrok http 4567"
puts "\nThen configure the ngrok URL in NOWPayments dashboard\n\n"
