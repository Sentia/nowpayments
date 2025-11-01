# frozen_string_literal: true

module NOWPayments
  module API
    # Estimation and calculation endpoints
    module Estimation
      # Get minimum payment amount for currency pair
      # GET /v1/min-amount
      # @param currency_from [String] Source currency code
      # @param currency_to [String] Target currency code
      # @return [Hash] Minimum amount info
      def min_amount(currency_from:, currency_to:)
        get("min-amount", params: {
              currency_from: currency_from,
              currency_to: currency_to
            }).body
      end

      # Estimate price for currency pair
      # GET /v1/estimate
      # @param amount [Numeric] Amount to estimate
      # @param currency_from [String] Source currency
      # @param currency_to [String] Target currency
      # @return [Hash] Price estimate
      def estimate(amount:, currency_from:, currency_to:)
        get("estimate", params: {
              amount: amount,
              currency_from: currency_from,
              currency_to: currency_to
            }).body
      end
    end
  end
end
