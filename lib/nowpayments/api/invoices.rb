# frozen_string_literal: true

module NOWPayments
  module API
    # Invoice-related endpoints
    module Invoices
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

      # Create payment by invoice
      # POST /v1/invoice-payment
      # @param iid [Integer, String] Invoice ID
      # @param pay_currency [String] Crypto currency
      # @param purchase_id [String, Integer, nil] Optional purchase ID
      # @param order_description [String, nil] Optional description
      # @param customer_email [String, nil] Optional customer email
      # @param payout_address [String, nil] Optional custom payout address
      # @param payout_extra_id [String, nil] Optional extra ID for payout
      # @param payout_currency [String, nil] Required if payout_address set
      # @return [Hash] Payment details
      def create_invoice_payment(
        iid:,
        pay_currency:,
        purchase_id: nil,
        order_description: nil,
        customer_email: nil,
        payout_address: nil,
        payout_extra_id: nil,
        payout_currency: nil
      )
        params = {
          iid: iid,
          pay_currency: pay_currency
        }

        params[:purchase_id] = purchase_id if purchase_id
        params[:order_description] = order_description if order_description
        params[:customer_email] = customer_email if customer_email
        params[:payout_address] = payout_address if payout_address
        params[:payout_extra_id] = payout_extra_id if payout_extra_id
        params[:payout_currency] = payout_currency if payout_currency

        post("invoice-payment", body: params).body
      end

      # Get invoice details and status
      # GET /v1/invoice/:invoice_id
      # @param invoice_id [String, Integer] Invoice ID
      # @return [Hash] Invoice details with payment status
      def invoice(invoice_id)
        get("invoice/#{invoice_id}").body
      end
    end
  end
end
