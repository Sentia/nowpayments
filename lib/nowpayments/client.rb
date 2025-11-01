# frozen_string_literal: true

require "faraday"
require "json"
require_relative "api/status"
require_relative "api/authentication"
require_relative "api/currencies"
require_relative "api/estimation"
require_relative "api/payments"
require_relative "api/invoices"
require_relative "api/payouts"
require_relative "api/subscriptions"
require_relative "api/conversions"
require_relative "api/custody"
require_relative "api/fiat_payouts"

module NOWPayments
  # Main client for interacting with the NOWPayments API
  class Client
    include API::Status
    include API::Authentication
    include API::Currencies
    include API::Estimation
    include API::Payments
    include API::Invoices
    include API::Payouts
    include API::Subscriptions
    include API::Conversions
    include API::Custody
    include API::FiatPayouts

    attr_reader :api_key, :ipn_secret, :sandbox
    attr_accessor :jwt_token, :jwt_expires_at

    BASE_URL = "https://api.nowpayments.io/v1"
    SANDBOX_URL = "https://api-sandbox.nowpayments.io/v1"

    def initialize(api_key:, ipn_secret: nil, sandbox: false)
      @api_key = api_key
      @ipn_secret = ipn_secret
      @sandbox = sandbox
      @jwt_token = nil
      @jwt_expires_at = nil
    end

    def base_url
      sandbox ? SANDBOX_URL : BASE_URL
    end

    private

    def connection
      @connection ||= Faraday.new(url: base_url) do |faraday|
        faraday.request :json
        faraday.response :json, content_type: /\bjson$/
        faraday.adapter Faraday.default_adapter
        faraday.headers["x-api-key"] = @api_key

        # Add JWT Bearer token if available and not expired
        faraday.headers["Authorization"] = "Bearer #{@jwt_token}" if @jwt_token && !jwt_expired?
      end
    end

    # Reset connection when JWT token changes
    def reset_connection!
      @connection = nil
    end

    def get(path, params: {})
      connection.get(path, params)
    end

    def post(path, body: {})
      connection.post(path, body.to_json)
    end

    def patch(path, body: {})
      connection.patch(path, body.to_json)
    end

    def delete(path, params: {})
      connection.delete(path, params)
    end

    def validate_payment_params!(params)
      return unless params[:payout_address] && !params[:payout_currency]

      raise ValidationError, "payout_currency required when payout_address is set"
    end
  end
end
