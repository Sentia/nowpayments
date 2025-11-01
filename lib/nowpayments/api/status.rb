# frozen_string_literal: true

module NOWPayments
  module API
    # Status and utility endpoints
    module Status
      # Check API status
      # GET /v1/status
      # @return [Hash] Status response
      def status
        get("status").body
      end
    end
  end
end
