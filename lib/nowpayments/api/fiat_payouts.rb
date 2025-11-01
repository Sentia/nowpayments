# frozen_string_literal: true

module NOWPayments
  module API
    # Fiat Payouts API endpoints (Beta)
    # All endpoints require JWT authentication
    # Note: This is a Beta feature with limited availability
    module FiatPayouts
      # Get available fiat payment methods
      # GET /v1/fiat-payouts/payment-methods
      # @param fiat_currency [String, nil] Optional filter by fiat currency (e.g., "EUR", "USD")
      # @return [Hash] Available payment methods
      def fiat_payout_payment_methods(fiat_currency: nil)
        params = {}
        params[:fiatCurrency] = fiat_currency if fiat_currency
        get("fiat-payouts/payment-methods", params: params).body
      end

      # Create a fiat payout account
      # POST /v1/fiat-payouts/account
      # @param provider [String] Payment provider (e.g., "transfi")
      # @param fiat_currency [String] Fiat currency code (e.g., "EUR", "USD")
      # @param account_data [Hash] Provider-specific account data
      # @return [Hash] Created account details
      def create_fiat_payout_account(provider:, fiat_currency:, account_data:)
        params = {
          provider: provider,
          fiatCurrency: fiat_currency,
          accountData: account_data
        }
        post("fiat-payouts/account", body: params).body
      end

      # Get list of fiat payout accounts
      # GET /v1/fiat-payouts/account
      # @param provider [String, nil] Optional filter by provider
      # @param fiat_currency [String, nil] Optional filter by fiat currency
      # @param limit [Integer] Number of results per page (default: 10)
      # @param page [Integer] Page number (default: 0)
      # @return [Hash] List of payout accounts
      def fiat_payout_accounts(provider: nil, fiat_currency: nil, limit: 10, page: 0)
        params = { limit: limit, page: page }
        params[:provider] = provider if provider
        params[:fiatCurrency] = fiat_currency if fiat_currency
        get("fiat-payouts/account", params: params).body
      end

      # Update a fiat payout account
      # PATCH /v1/fiat-payouts/account/:account_id
      # @param account_id [String, Integer] Account ID
      # @param account_data [Hash] Updated account data
      # @return [Hash] Updated account details
      def update_fiat_payout_account(account_id:, account_data:)
        params = { accountData: account_data }
        patch("fiat-payouts/account/#{account_id}", body: params).body
      end

      # Create a fiat payout
      # POST /v1/fiat-payouts
      # @param account_id [String, Integer] Payout account ID
      # @param crypto_currency [String] Cryptocurrency code (e.g., "btc", "eth")
      # @param crypto_amount [Numeric] Amount in cryptocurrency
      # @param request_id [String, nil] Optional unique request ID
      # @return [Hash] Created payout details
      def create_fiat_payout(account_id:, crypto_currency:, crypto_amount:, request_id: nil)
        params = {
          accountId: account_id,
          cryptoCurrency: crypto_currency,
          cryptoAmount: crypto_amount
        }
        params[:requestId] = request_id if request_id
        post("fiat-payouts", body: params).body
      end

      # Get fiat payout status
      # GET /v1/fiat-payouts/:payout_id
      # @param payout_id [String, Integer] Payout ID
      # @return [Hash] Payout details and status
      def fiat_payout_status(payout_id)
        get("fiat-payouts/#{payout_id}").body
      end

      # Get list of fiat payouts
      # GET /v1/fiat-payouts
      # @param id [String, Integer, nil] Optional filter by payout ID
      # @param provider [String, nil] Optional filter by provider
      # @param request_id [String, nil] Optional filter by request ID
      # @param fiat_currency [String, nil] Optional filter by fiat currency
      # @param crypto_currency [String, nil] Optional filter by crypto currency
      # @param status [String, nil] Optional filter by status (e.g., "FINISHED", "PENDING")
      # @param filter [String, nil] Optional text filter
      # @param provider_payout_id [String, nil] Optional filter by provider's payout ID
      # @param limit [Integer] Number of results per page (default: 10)
      # @param page [Integer] Page number (default: 0)
      # @param order_by [String, nil] Optional field to order by
      # @param sort_by [String, nil] Optional sort direction ("asc" or "desc")
      # @param date_from [String, nil] Optional start date (ISO 8601)
      # @param date_to [String, nil] Optional end date (ISO 8601)
      # @return [Hash] List of payouts
      def fiat_payouts(
        id: nil,
        provider: nil,
        request_id: nil,
        fiat_currency: nil,
        crypto_currency: nil,
        status: nil,
        filter: nil,
        provider_payout_id: nil,
        limit: 10,
        page: 0,
        order_by: nil,
        sort_by: nil,
        date_from: nil,
        date_to: nil
      )
        params = { limit: limit, page: page }
        params[:id] = id if id
        params[:provider] = provider if provider
        params[:requestId] = request_id if request_id
        params[:fiatCurrency] = fiat_currency if fiat_currency
        params[:cryptoCurrency] = crypto_currency if crypto_currency
        params[:status] = status if status
        params[:filter] = filter if filter
        params[:provider_payout_id] = provider_payout_id if provider_payout_id
        params[:orderBy] = order_by if order_by
        params[:sortBy] = sort_by if sort_by
        params[:dateFrom] = date_from if date_from
        params[:dateTo] = date_to if date_to
        get("fiat-payouts", params: params).body
      end

      # Get fiat conversion rates
      # POST /v1/fiat-payouts/rates
      # @param crypto_currency [String] Cryptocurrency code (e.g., "btc", "eth")
      # @param fiat_currency [String] Fiat currency code (e.g., "EUR", "USD")
      # @param crypto_amount [Numeric, nil] Optional crypto amount to convert
      # @param fiat_amount [Numeric, nil] Optional fiat amount to convert
      # @return [Hash] Conversion rates and amounts
      def fiat_payout_rates(crypto_currency:, fiat_currency:, crypto_amount: nil, fiat_amount: nil)
        params = {
          cryptoCurrency: crypto_currency,
          fiatCurrency: fiat_currency
        }
        params[:cryptoAmount] = crypto_amount if crypto_amount
        params[:fiatAmount] = fiat_amount if fiat_amount
        post("fiat-payouts/rates", body: params).body
      end
    end
  end
end
