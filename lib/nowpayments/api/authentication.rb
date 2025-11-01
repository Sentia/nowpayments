# frozen_string_literal: true

module NOWPayments
  module API
    # JWT authentication endpoints
    module Authentication
      # Authenticate and obtain JWT token
      # POST /v1/auth
      # JWT tokens expire in 5 minutes for security reasons
      # @param email [String] Your NOWPayments dashboard email (case-sensitive)
      # @param password [String] Your NOWPayments dashboard password (case-sensitive)
      # @return [Hash] Authentication response with JWT token
      # @note Email and password are case-sensitive. test@gmail.com != Test@gmail.com
      def authenticate(email:, password:)
        response = post("auth", body: {
                          email: email,
                          password: password
                        })

        # Store token and expiry time (5 minutes from now)
        if response.body["token"]
          @jwt_token = response.body["token"]
          @jwt_expires_at = Time.now + 300 # 5 minutes = 300 seconds

          # Reset connection to include new Bearer token
          reset_connection! if respond_to?(:reset_connection!, true)
        end

        response.body
      end

      # Get current JWT token (refreshes if expired)
      # @param email [String, nil] Email for re-authentication if token expired
      # @param password [String, nil] Password for re-authentication if token expired
      # @return [String, nil] Current valid JWT token or nil
      def jwt_token(email: nil, password: nil)
        # Auto-refresh if expired and credentials provided
        authenticate(email: email, password: password) if jwt_expired? && email && password

        @jwt_token
      end

      # Check if JWT token is expired
      # @return [Boolean] True if token is expired or not set
      def jwt_expired?
        !@jwt_token || !@jwt_expires_at || Time.now >= @jwt_expires_at
      end

      # Manually clear JWT token (e.g., for logout)
      # @return [void]
      def clear_jwt_token
        @jwt_token = nil
        @jwt_expires_at = nil
      end

      # Get time remaining until JWT token expires
      # @return [Integer, nil] Seconds until expiry, or nil if no token
      def jwt_time_remaining
        return nil unless @jwt_token && @jwt_expires_at

        remaining = (@jwt_expires_at - Time.now).to_i
        remaining.positive? ? remaining : 0
      end
    end
  end
end
