# frozen_string_literal: true

module NOWPayments
  module API
    # Conversion endpoints (requires JWT auth)
    module Conversions
      # Create a new conversion between currencies
      # POST /v1/conversion
      # Requires JWT authentication
      # @param from_currency [String] Source currency code
      # @param to_currency [String] Target currency code
      # @param amount [Numeric] Amount to convert
      # @return [Hash] Conversion details
      def create_conversion(from_currency:, to_currency:, amount:)
        post("conversion", body: {
               from_currency: from_currency,
               to_currency: to_currency,
               amount: amount
             }).body
      end

      # Get status of a specific conversion
      # GET /v1/conversion/:conversion_id
      # Requires JWT authentication
      # @param conversion_id [String, Integer] Conversion ID
      # @return [Hash] Conversion status details
      def conversion_status(conversion_id)
        get("conversion/#{conversion_id}").body
      end

      # List all conversions with pagination
      # GET /v1/conversion
      # Requires JWT authentication
      # @param limit [Integer] Results per page
      # @param offset [Integer] Offset for pagination
      # @return [Hash] List of conversions
      def list_conversions(limit: 10, offset: 0)
        get("conversion", params: { limit: limit, offset: offset }).body
      end
    end
  end
end
