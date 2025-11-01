# frozen_string_literal: true

module NOWPayments
  module API
    # Payment-related endpoints
    module Payments
      # Create a new payment
      # POST /v1/payment
      # @param price_amount [Numeric] Fiat amount
      # @param price_currency [String] Fiat currency
      # @param pay_currency [String] Crypto currency customer pays with
      # @param pay_amount [Numeric, nil] Optional crypto amount (alternative to price_amount)
      # @param order_id [String, nil] Optional merchant order ID
      # @param order_description [String, nil] Optional description
      # @param ipn_callback_url [String, nil] Optional webhook URL
      # @param payout_address [String, nil] Optional custom payout address
      # @param payout_currency [String, nil] Required if payout_address set
      # @param payout_extra_id [String, nil] Optional extra ID for payout
      # @param is_fixed_rate [Boolean, nil] Fixed rate flag
      # @param is_fee_paid_by_user [Boolean, nil] Whether user pays network fees
      # @return [Hash] Payment details
      def create_payment(
        price_amount:,
        price_currency:,
        pay_currency:,
        pay_amount: nil,
        order_id: nil,
        order_description: nil,
        ipn_callback_url: nil,
        payout_address: nil,
        payout_currency: nil,
        payout_extra_id: nil,
        is_fixed_rate: nil,
        is_fee_paid_by_user: nil
      )
        params = {
          price_amount: price_amount,
          price_currency: price_currency,
          pay_currency: pay_currency
        }

        params[:pay_amount] = pay_amount if pay_amount
        params[:order_id] = order_id if order_id
        params[:order_description] = order_description if order_description
        params[:ipn_callback_url] = ipn_callback_url if ipn_callback_url
        params[:payout_address] = payout_address if payout_address
        params[:payout_currency] = payout_currency if payout_currency
        params[:payout_extra_id] = payout_extra_id if payout_extra_id
        params[:is_fixed_rate] = is_fixed_rate unless is_fixed_rate.nil?
        params[:is_fee_paid_by_user] = is_fee_paid_by_user unless is_fee_paid_by_user.nil?

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
    end
  end
end
