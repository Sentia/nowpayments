# frozen_string_literal: true

module NOWPayments
  module API
    # Payout and mass payout endpoints (requires JWT auth)
    module Payouts
      # Get account balance
      # GET /v1/balance
      # @return [Hash] Balance information with available and pending amounts per currency
      def balance
        get("balance").body
      end

      # Validate payout address
      # POST /v1/payout/validate-address
      # @param address [String] Payout address to validate
      # @param currency [String] Currency code
      # @param extra_id [String, nil] Optional memo/tag/destination tag
      # @return [Hash] Validation result
      def validate_payout_address(address:, currency:, extra_id: nil)
        params = {
          address: address,
          currency: currency
        }
        params[:extra_id] = extra_id if extra_id

        post("payout/validate-address", body: params).body
      end

      # Create payout
      # POST /v1/payout
      # Note: This endpoint requires JWT authentication
      # @param withdrawals [Array<Hash>] Array of withdrawal objects
      #   Each withdrawal should have:
      #   - address (String, required): Crypto address
      #   - currency (String, required): Currency code
      #   - amount (Numeric, required): Amount to send
      #   - ipn_callback_url (String, optional): Individual callback URL
      #   - extra_id (String, optional): Payment extra ID (memo/tag)
      #   - fiat_amount (Numeric, optional): Fiat equivalent amount
      #   - fiat_currency (String, optional): Fiat currency code
      #   - unique_external_id (String, optional): External reference ID
      #   - payout_description (String, optional): Individual description
      # @param payout_description [String, nil] Description for entire batch
      # @param ipn_callback_url [String, nil] Callback URL for entire batch
      # @return [Hash] Payout result
      def create_payout(withdrawals:, payout_description: nil, ipn_callback_url: nil)
        params = { withdrawals: withdrawals }
        params[:payout_description] = payout_description if payout_description
        params[:ipn_callback_url] = ipn_callback_url if ipn_callback_url

        post("payout", body: params).body
      end

      # Verify payout with 2FA code
      # POST /v1/payout/:batch_withdrawal_id/verify
      # @param batch_withdrawal_id [String, Integer] Batch withdrawal ID from create_payout
      # @param verification_code [String] 2FA code from Google Auth app or email
      # @return [Hash] Verification result
      def verify_payout(batch_withdrawal_id:, verification_code:)
        post("payout/#{batch_withdrawal_id}/verify", body: {
               verification_code: verification_code
             }).body
      end

      # Get payout status
      # GET /v1/payout/:payout_id
      # @param payout_id [String, Integer] Payout ID
      # @return [Hash] Payout status and details
      def payout_status(payout_id)
        get("payout/#{payout_id}").body
      end

      # List payouts with pagination
      # GET /v1/payout
      # @param limit [Integer] Results per page
      # @param offset [Integer] Offset for pagination
      # @return [Hash] List of payouts
      def list_payouts(limit: 10, offset: 0)
        get("payout", params: {
              limit: limit,
              offset: offset
            }).body
      end

      # Get minimum payout amount
      # GET /v1/payout/min-amount
      # @param currency [String] Currency code
      # @return [Hash] Minimum payout amount for currency
      def min_payout_amount(currency:)
        get("payout/min-amount", params: { currency: currency }).body
      end

      # Get payout fee estimate
      # GET /v1/payout/fee
      # @param currency [String] Currency code
      # @param amount [Numeric] Payout amount
      # @return [Hash] Fee estimate
      def payout_fee(currency:, amount:)
        get("payout/fee", params: {
              currency: currency,
              amount: amount
            }).body
      end
    end
  end
end
