# frozen_string_literal: true

module NOWPayments
  # Base error class for all NOWPayments errors
  class Error < StandardError
    attr_reader :status, :body, :headers

    def initialize(env_or_message)
      if env_or_message.is_a?(Hash)
        @status = env_or_message[:status]
        @body = env_or_message[:body]
        @headers = env_or_message[:response_headers]
        super(error_message)
      else
        super(env_or_message)
      end
    end

    private

    def error_message
      if body.is_a?(Hash) && body["message"]
        "#{self.class.name}: #{body["message"]} (HTTP #{status})"
      elsif body.is_a?(String)
        "#{self.class.name}: #{body} (HTTP #{status})"
      else
        "#{self.class.name}: HTTP #{status}"
      end
    end
  end

  # Connection-level errors
  class ConnectionError < Error
    def initialize(message)
      @message = message
      super(message)
    end
  end

  # HTTP 400 - Bad Request
  class BadRequestError < Error; end

  # HTTP 401, 403 - Authentication/Authorization errors
  class AuthenticationError < Error; end

  # HTTP 404 - Resource Not Found
  class NotFoundError < Error; end

  # HTTP 429 - Rate Limit Exceeded
  class RateLimitError < Error; end

  # HTTP 500-599 - Server errors
  class ServerError < Error; end

  # Security/verification errors (e.g., invalid IPN signature)
  class SecurityError < StandardError; end

  # Client-side validation errors
  class ValidationError < StandardError; end
end
