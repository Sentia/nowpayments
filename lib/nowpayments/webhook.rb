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

        parsed = JSON.parse(raw_body)
        sorted_json = sort_keys_recursive(parsed)
        expected_sig = generate_signature(sorted_json, secret)

        unless secure_compare(expected_sig, signature)
          raise SecurityError, "Invalid IPN signature - webhook verification failed"
        end

        parsed
      end

      private

      # Recursively sort Hash keys (including nested hashes and arrays)
      # This is critical for proper HMAC signature verification
      def sort_keys_recursive(obj)
        case obj
        when Hash
          Hash[obj.sort].transform_values { |v| sort_keys_recursive(v) }
        when Array
          obj.map { |v| sort_keys_recursive(v) }
        else
          obj
        end
      end

      # Generate HMAC-SHA512 signature
      def generate_signature(sorted_json, secret)
        json_string = JSON.generate(sorted_json, space: "", indent: "")
        OpenSSL::HMAC.hexdigest("SHA512", secret, json_string)
      end

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
