# frozen_string_literal: true

require "faraday"
require "json"

module NOWPayments
  # Main client for interacting with the NOWPayments API
  class Client
    attr_reader :api_key, :ipn_secret, :sandbox

    BASE_URL = "https://api.nowpayments.io/v1"
    SANDBOX_URL = "https://api-sandbox.nowpayments.io/v1"

    def initialize(api_key:, ipn_secret: nil, sandbox: false)
      @api_key = api_key
      @ipn_secret = ipn_secret
      @sandbox = sandbox
    end

    def base_url
      sandbox ? SANDBOX_URL : BASE_URL
    end

    # ============================================
    # STATUS & UTILITY ENDPOINTS
    # ============================================

    # Check API status
    # GET /v1/status
    # @return [Hash] Status response
    def status
      get("status").body
    end

    # Get list of available currencies
    # GET /v1/currencies
    # @return [Hash] Available currencies
    def currencies
      get("currencies").body
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

    # ============================================
    # ESTIMATION & CALCULATION ENDPOINTS
    # ============================================

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

    # ============================================
    # PAYMENT ENDPOINTS
    # ============================================

    # Create a new payment
    # POST /v1/payment
    # @param price_amount [Numeric] Fiat amount
    # @param price_currency [String] Fiat currency
    # @param pay_currency [String] Crypto currency customer pays with
    # @param order_id [String, nil] Optional merchant order ID
    # @param order_description [String, nil] Optional description
    # @param ipn_callback_url [String, nil] Optional webhook URL
    # @param payout_address [String, nil] Optional custom payout address
    # @param payout_currency [String, nil] Required if payout_address set
    # @param payout_extra_id [String, nil] Optional extra ID for payout
    # @param fixed_rate [Boolean, nil] Fixed rate payment
    # @return [Hash] Payment details
    def create_payment(
      price_amount:,
      price_currency:,
      pay_currency:,
      order_id: nil,
      order_description: nil,
      ipn_callback_url: nil,
      payout_address: nil,
      payout_currency: nil,
      payout_extra_id: nil,
      fixed_rate: nil
    )
      params = {
        price_amount: price_amount,
        price_currency: price_currency,
        pay_currency: pay_currency
      }

      params[:order_id] = order_id if order_id
      params[:order_description] = order_description if order_description
      params[:ipn_callback_url] = ipn_callback_url if ipn_callback_url
      params[:payout_address] = payout_address if payout_address
      params[:payout_currency] = payout_currency if payout_currency
      params[:payout_extra_id] = payout_extra_id if payout_extra_id
      params[:fixed_rate] = fixed_rate unless fixed_rate.nil?

      validate_payment_params!(params)

      post("payment", body: params).body
    end

    # Get payment status
    # GET /v1/payment/:payment_id
    # @param payment_id [Integer, String] Payment ID
    # @return [Hash] Payment status
    def payment(payment_id)
      get("payment/#{payment_id}").body
    end

    # List payments with pagination and filters
    # GET /v1/payment
    # @param limit [Integer] Results per page
    # @param page [Integer] Page number
    # @param sort_by [String, nil] Sort field
    # @param order_by [String, nil] Order direction (asc/desc)
    # @param date_from [String, nil] Start date filter
    # @param date_to [String, nil] End date filter
    # @return [Hash] List of payments
    def payments(limit: 10, page: 0, sort_by: nil, order_by: nil, date_from: nil, date_to: nil)
      params = { limit: limit, page: page }
      params[:sortBy] = sort_by if sort_by
      params[:orderBy] = order_by if order_by
      params[:dateFrom] = date_from if date_from
      params[:dateTo] = date_to if date_to

      get("payment", params: params).body
    end

    # Update payment estimate
    # PATCH /v1/payment/:payment_id
    # @param payment_id [Integer, String] Payment ID
    # @return [Hash] Updated payment
    def update_payment_estimate(payment_id)
      patch("payment/#{payment_id}").body
    end

    # ============================================
    # INVOICE ENDPOINTS
    # ============================================

    # Create an invoice (hosted payment page)
    # POST /v1/invoice
    # @param price_amount [Numeric] Fiat amount
    # @param price_currency [String] Fiat currency
    # @param pay_currency [String, nil] Optional crypto (if nil, customer chooses)
    # @param order_id [String, nil] Optional merchant order ID
    # @param order_description [String, nil] Optional description
    # @param ipn_callback_url [String, nil] Optional webhook URL
    # @param success_url [String, nil] Optional redirect after success
    # @param cancel_url [String, nil] Optional redirect after cancel
    # @return [Hash] Invoice with invoice_url
    def create_invoice(
      price_amount:,
      price_currency:,
      pay_currency: nil,
      order_id: nil,
      order_description: nil,
      ipn_callback_url: nil,
      success_url: nil,
      cancel_url: nil
    )
      params = {
        price_amount: price_amount,
        price_currency: price_currency
      }

      params[:pay_currency] = pay_currency if pay_currency
      params[:order_id] = order_id if order_id
      params[:order_description] = order_description if order_description
      params[:ipn_callback_url] = ipn_callback_url if ipn_callback_url
      params[:success_url] = success_url if success_url
      params[:cancel_url] = cancel_url if cancel_url

      post("invoice", body: params).body
    end

    # ============================================
    # PAYOUT ENDPOINTS (Requires JWT Auth)
    # ============================================

    # Create payout
    # POST /v1/payout
    # Note: This endpoint typically requires JWT authentication
    # @param withdrawals [Array<Hash>] Array of withdrawal objects
    # @return [Hash] Payout result
    def create_payout(withdrawals:)
      post("payout", body: { withdrawals: withdrawals }).body
    end

    # ============================================
    # SUBSCRIPTION/RECURRING PAYMENT ENDPOINTS
    # ============================================

    # Get subscription plans
    # GET /v1/subscriptions/plans
    # @return [Hash] List of subscription plans
    def subscription_plans
      get("subscriptions/plans").body
    end

    # Create subscription plan
    # POST /v1/subscriptions/plans
    # @param plan_data [Hash] Plan configuration
    # @return [Hash] Created plan
    def create_subscription_plan(plan_data)
      post("subscriptions/plans", body: plan_data).body
    end

    # Get specific subscription plan
    # GET /v1/subscriptions/plans/:plan_id
    # @param plan_id [String, Integer] Plan ID
    # @return [Hash] Plan details
    def subscription_plan(plan_id)
      get("subscriptions/plans/#{plan_id}").body
    end

    # Create email subscription
    # POST /v1/subscriptions
    # @param plan_id [String] Subscription plan ID
    # @param email [String] Customer email
    # @return [Hash] Subscription result
    def create_subscription(plan_id:, email:)
      post("subscriptions", body: {
             plan_id: plan_id,
             email: email
           }).body
    end

    # Get subscription payments
    # GET /v1/subscriptions/:subscription_id/payments
    # @param subscription_id [String, Integer] Subscription ID
    # @return [Hash] Subscription payments
    def subscription_payments(subscription_id)
      get("subscriptions/#{subscription_id}/payments").body
    end

    private

    def connection
      @connection ||= Faraday.new(url: base_url) do |conn|
        conn.request :json
        conn.response :json, content_type: /\bjson$/
        conn.response :logger if ENV["DEBUG"] || ENV["NOWPAYMENTS_DEBUG"]
        conn.use Middleware::ErrorHandler
        conn.adapter Faraday.default_adapter

        conn.headers["x-api-key"] = api_key if api_key
      end
    end

    def get(path, params: {})
      connection.get(path, params)
    end

    def post(path, body: {})
      connection.post(path, body)
    end

    def patch(path, body: {})
      connection.patch(path, body)
    end

    def validate_payment_params!(params)
      return unless params[:payout_address] && !params[:payout_currency]

      raise ValidationError, "payout_currency required when payout_address is set"
    end
  end
end
