# frozen_string_literal: true

require "openssl"
require "json"

module NOWPayments
  # Webhook verification utilities for IPN (Instant Payment Notifications)
  module Webhook
    class << self
      # Verify IPN signature
      # @param raw_body [String] Raw POST body from webhook
      # @param signature [String] x-nowpayments-sig header value
      # @param secret [String] IPN secret key from dashboard
      # @return [Hash] Verified, parsed payload
      # @raise [SecurityError] If signature is invalid
      def verify!(raw_body, signature, secret)
        raise ArgumentError, "raw_body required" if raw_body.nil? || raw_body.empty?
        raise ArgumentError, "signature required" if signature.nil? || signature.empty?
        raise ArgumentError, "secret required" if secret.nil? || secret.empty?

        # Compute HMAC directly on raw body - NOWPayments already sends keys in sorted order.
        # DO NOT parse and re-serialize! Ruby's JSON.generate may change number formatting
        # (e.g., scientific notation "1e-7" becomes "0.0000001"), breaking the signature.
        expected_sig = OpenSSL::HMAC.hexdigest("SHA512", secret, raw_body)

        raise SecurityError, "Invalid IPN signature - webhook verification failed" unless secure_compare(expected_sig, signature)

        # Only parse after verification succeeds
        JSON.parse(raw_body)
      end

      private

      # Constant-time comparison to prevent timing attacks
      def secure_compare(a, b)
        return false unless a.bytesize == b.bytesize

        l = a.unpack("C#{a.bytesize}")
        res = 0
        b.each_byte { |byte| res |= byte ^ l.shift }
        res.zero?
      end
    end
  end
end
