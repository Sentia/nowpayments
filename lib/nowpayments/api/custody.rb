# frozen_string_literal: true

module NOWPayments
  module API
    # Custody/sub-partner endpoints for managing customer accounts
    module Custody
      # Create a new sub-account (user account)
      # POST /v1/sub-partner/balance
      # @param user_id [String] Unique user identifier (your internal user ID)
      # @return [Hash] Created sub-account details
      def create_sub_account(user_id:)
        post("sub-partner/balance", body: { Name: user_id }).body
      end

      # Get balance for a specific sub-account
      # GET /v1/sub-partner/balance/:user_id
      # @param user_id [String] User identifier (path parameter)
      # @return [Hash] User balance details
      def sub_account_balance(user_id)
        get("sub-partner/balance/#{user_id}").body
      end

      # Get balance for all sub-accounts
      # GET /v1/sub-partner/balance
      # @return [Hash] Array of all user balances
      def sub_account_balances
        get("sub-partner/balance").body
      end

      # List sub-accounts with filters
      # GET /v1/sub-partner
      # @param id [String, Integer, Array, nil] Filter by specific user ID(s)
      # @param limit [Integer] Results per page
      # @param offset [Integer] Offset for pagination
      # @param order [String] Sort order (ASC or DESC)
      # @return [Hash] List of sub-accounts
      def list_sub_accounts(id: nil, limit: 10, offset: 0, order: "ASC")
        params = { limit: limit, offset: offset, order: order }
        params[:id] = id if id

        get("sub-partner", params: params).body
      end

      # Transfer between sub-accounts
      # POST /v1/sub-partner/transfer
      # @param currency [String] Currency code
      # @param amount [Numeric] Amount to transfer
      # @param from_id [String, Integer] Source sub-account ID
      # @param to_id [String, Integer] Destination sub-account ID
      # @return [Hash] Transfer result
      def transfer_between_sub_accounts(currency:, amount:, from_id:, to_id:)
        post("sub-partner/transfer", body: {
               currency: currency,
               amount: amount,
               from_id: from_id,
               to_id: to_id
             }).body
      end

      # Create deposit request for sub-account (external crypto deposit)
      # POST /v1/sub-partner/deposit
      # @param user_id [String] User identifier
      # @param currency [String] Cryptocurrency code
      # @param amount [Numeric, nil] Optional amount
      # @return [Hash] Deposit address and details
      def create_sub_account_deposit(user_id:, currency:, amount: nil)
        params = {
          Name: user_id,
          currency: currency
        }
        params[:amount] = amount if amount

        post("sub-partner/deposit", body: params).body
      end

      # Create payment deposit for sub-account
      # POST /v1/sub-partner/payment
      # @param sub_partner_id [String, Integer] Sub-account ID
      # @param currency [String] Currency code
      # @param amount [Numeric] Payment amount
      # @param fixed_rate [Boolean, nil] Fixed rate flag
      # @return [Hash] Payment deposit details
      def create_sub_account_payment_deposit(sub_partner_id:, currency:, amount:, fixed_rate: nil)
        params = {
          sub_partner_id: sub_partner_id,
          currency: currency,
          amount: amount
        }
        params[:fixed_rate] = fixed_rate unless fixed_rate.nil?

        post("sub-partner/payment", body: params).body
      end

      # Transfer funds from master account to sub-account
      # POST /v1/sub-partner/deposit-from-master
      # @param user_id [String] User identifier
      # @param currency [String] Cryptocurrency code
      # @param amount [Numeric] Amount to transfer
      # @return [Hash] Transfer result
      def transfer_to_sub_account(user_id:, currency:, amount:)
        post("sub-partner/deposit-from-master", body: {
               Name: user_id,
               currency: currency,
               amount: amount
             }).body
      end

      # Write-off (withdraw) funds from sub-account to master account
      # POST /v1/sub-partner/write-off
      # @param user_id [String] User identifier
      # @param currency [String] Cryptocurrency code
      # @param amount [Numeric] Amount to withdraw
      # @return [Hash] Write-off result
      def withdraw_from_sub_account(user_id:, currency:, amount:)
        post("sub-partner/write-off", body: {
               Name: user_id,
               currency: currency,
               amount: amount
             }).body
      end

      # Get details of a specific transfer
      # GET /v1/sub-partner/transfer
      # @param transfer_id [String, Integer] Transfer ID
      # @return [Hash] Transfer details
      def sub_account_transfer(transfer_id)
        get("sub-partner/transfer", params: { id: transfer_id }).body
      end

      # Get list of all transfers
      # GET /v1/sub-partner/transfers
      # @param id [String, Integer, Array, nil] Filter by specific transfer ID(s)
      # @param status [String, Array, nil] Filter by status (CREATED, WAITING, FINISHED, REJECTED)
      # @param limit [Integer] Results per page
      # @param offset [Integer] Offset for pagination
      # @param order [String] Sort order (ASC or DESC)
      # @return [Hash] List of transfers
      def sub_account_transfers(id: nil, status: nil, limit: 10, offset: 0, order: "ASC")
        params = { limit: limit, offset: offset, order: order }
        params[:id] = id if id
        params[:status] = status if status

        get("sub-partner/transfers", params: params).body
      end
    end
  end
end
