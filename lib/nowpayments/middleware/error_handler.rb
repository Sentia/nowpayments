# frozen_string_literal: true

require "faraday"

module NOWPayments
  module Middleware
    # Faraday middleware that converts HTTP errors into NOWPayments exceptions
    class ErrorHandler < Faraday::Middleware
      def on_complete(env)
        case env[:status]
        when 400
          raise BadRequestError, env
        when 401, 403
          raise AuthenticationError, env
        when 404
          raise NotFoundError, env
        when 429
          raise RateLimitError, env
        when 500..599
          raise ServerError, env
        end
      end

      def call(env)
        @app.call(env).on_complete do |response_env|
          on_complete(response_env)
        end
      rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
        raise ConnectionError, e.message
      end
    end
  end
end

