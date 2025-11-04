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
      # @raise [AuthenticationError] if credentials are invalid or access is denied
      # @note Email and password are case-sensitive. test@gmail.com != Test@gmail.com
      def authenticate(email:, password:)
        response = post("auth", body: {
                          email: email,
                          password: password
                        })

        # Check for authentication errors
        if response.body.is_a?(Hash)
          # Handle 403 ACCESS_DENIED error
          if response.body["statusCode"] == 403 || response.body["code"] == "ACCESS_DENIED"
            error_msg = "Authentication failed: #{response.body["message"] || "Access denied"}. "
            
            if sandbox
              error_msg += "You are using SANDBOX mode. "
              error_msg += "Please verify:\n"
              error_msg += "   1. You have a sandbox account at https://sandbox.nowpayments.io/\n"
              error_msg += "   2. Your email and password are correct (case-sensitive)\n"
              error_msg += "   3. Your sandbox account has API access enabled"
            else
              error_msg += "You are using PRODUCTION mode. "
              error_msg += "Please verify:\n"
              error_msg += "   1. Your NOWPayments account at https://nowpayments.io/ has API access enabled\n"
              error_msg += "   2. Go to Settings → API → Enable API access if not already enabled\n"
              error_msg += "   3. Your email and password are correct (case-sensitive)\n"
              error_msg += "   4. If testing, you may need to use sandbox: true and sandbox credentials"
            end
            
            raise AuthenticationError.new(
              status: response.body["statusCode"],
              body: { "message" => error_msg },
              response_headers: response.headers
            )
          end
          
          # Handle other error responses
          status_code = response.body["statusCode"]&.to_i || 0
          if response.body["status"] == false || (status_code > 0 && status_code >= 400)
            error_msg = response.body["message"] || "Authentication failed"
            raise AuthenticationError.new(
              status: status_code,
              body: { "message" => error_msg },
              response_headers: response.headers
            )
          end
        end

        # Store token and expiry time (5 minutes from now)
        if response.body["token"]
          @jwt_token = response.body["token"]
          @jwt_expires_at = Time.now + 300 # 5 minutes = 300 seconds

          # Reset connection to include new Bearer token
          reset_connection! if respond_to?(:reset_connection!, true)
        else
          # No token in response - authentication failed
          raise AuthenticationError, "Authentication failed: No token received. Check your email and password."
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
