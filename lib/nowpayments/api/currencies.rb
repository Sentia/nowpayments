# frozen_string_literal: true

module NOWPayments
  module API
    # Currency-related endpoints
    module Currencies
      # Get list of available currencies
      # GET /v1/currencies
      # @param fixed_rate [Boolean, nil] Optional flag to get currencies with min/max exchange amounts
      # @return [Hash] Available currencies
      def currencies(fixed_rate: nil)
        params = {}
        params[:fixed_rate] = fixed_rate unless fixed_rate.nil?
        get("currencies", params: params).body
      end

      # Get list of available currencies with full info
      # GET /v1/full-currencies
      # @return [Hash] Full currency information
      def full_currencies
        get("full-currencies").body
      end

      # Get list of available currencies checked by merchant
      # GET /v1/merchant/coins
      # @return [Hash] Merchant's checked currencies
      def merchant_coins
        get("merchant/coins").body
      end
    end
  end
end
