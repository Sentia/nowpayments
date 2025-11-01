# frozen_string_literal: true

require_relative "nowpayments/version"
require_relative "nowpayments/errors"
require_relative "nowpayments/middleware/error_handler"
require_relative "nowpayments/client"
require_relative "nowpayments/webhook"
require_relative "nowpayments/rack"

module Nowpayments
  class Error < StandardError; end
  # Your code goes here...
end
