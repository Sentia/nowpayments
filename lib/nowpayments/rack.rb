# frozen_string_literal: true

module NOWPayments
  # Rack/Rails integration helpers for webhook verification
  module Rack
    # Verify webhook from a Rack/Rails request object
    # @param request [Rack::Request, ActionDispatch::Request] The request object
    # @param ipn_secret [String] IPN secret key
    # @return [Hash] Verified payload
    # @raise [SecurityError] If verification fails
    def self.verify_webhook(request, ipn_secret)
      raw_body = request.body.read
      request.body.rewind # Allow re-reading

      # Try both header access methods (Rack vs Rails)
      signature = request.get_header("HTTP_X_NOWPAYMENTS_SIG") if request.respond_to?(:get_header)
      signature ||= request.headers["x-nowpayments-sig"] if request.respond_to?(:headers)
      signature ||= request.env["HTTP_X_NOWPAYMENTS_SIG"]

      raise SecurityError, "Missing x-nowpayments-sig header" unless signature

      Webhook.verify!(raw_body, signature, ipn_secret)
    end
  end
end
